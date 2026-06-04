#!/usr/bin/env luajit
-- tmux-leap popup.
--
-- This is a terminal/tmux adaptation of leap.nvim's core implementation.  The
-- label assignment, grouping, preview phases, target ranking, equivalence-class
-- handling and beacon/conflict logic below are intentionally copied/adapted from
-- leap.nvim's generated Lua where possible.

-- ── defaults copied from leap.nvim/lua/leap/opts.lua ─────────────────────────

local DEFAULT_LABELS =
    "sfnjklhodweimbuyvrgtaqpcxz/" ..
    "SFNJKLHODWEIMBUYVRGTAQPCXZ?"

-- Upstream leap.nvim default is "sfnut/SFNLHMUGTZ?".  This dotfiles' Neovim
-- config sets `require('leap').opts.safe_labels = {}`, so tmux-leap defaults to
-- the same no-autojump behaviour.  Set @leap-safe-labels to opt back in.
local DEFAULT_SAFE_LABELS = ""

local opts = {
    preview = true,
    equivalence_classes = {" \t\r\n"},
    safe_labels = DEFAULT_SAFE_LABELS,
    labels = DEFAULT_LABELS,
    keys = {
        next_target = {"\r", "\n"},
        prev_target = {"\127", "\8"},
        next_group = {" "},
        prev_group = {"\127", "\8"},
    },
    case_sensitive = nil,
    ignorecase = true,
    smartcase = true,
    substitute_chars = {},
    concealed_label = " ",
}

local hl = {
    group = {
        label = "LeapLabel",
        ["label-dimmed"] = "LeapLabelDimmed",
    },
}

-- ANSI approximations of LeapLabel/LeapLabelDimmed.
local STYLE = {
    LeapLabel = "\027[30;48;5;193m\027[1m",       -- black on pale green, bold
    LeapLabelDimmed = "\027[38;5;243m\027[1m",    -- dim gray
}
local RESET = "\027[0m"
local HIDE  = "\027[?25l"
local SHOW  = "\027[?25h"
local INDICATOR = STYLE.LeapLabel

local min = math.min
local max = math.max
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local sqrt = math.sqrt

-- ── small Lua/Vim compatibility helpers ─────────────────────────────────────

local function clamp(x, lo, hi)
    if x < lo then return lo end
    if x > hi then return hi end
    return x
end

local function parse_bool(v)
    if v == nil or v == "" then return nil end
    v = v:lower()
    if v == "1" or v == "true" or v == "yes" or v == "on" then return true end
    if v == "0" or v == "false" or v == "no" or v == "off" then return false end
    return nil
end

local function env_bool(name, default)
    local parsed = parse_bool(os.getenv(name))
    if parsed == nil then return default end
    return parsed
end

local function load_opts_from_env()
    local labels = os.getenv("LEAP_LABELS")
    if labels ~= nil and labels ~= "" then opts.labels = labels end
    local safe = os.getenv("LEAP_SAFE_LABELS")
    if safe ~= nil then opts.safe_labels = safe end
    opts.ignorecase = env_bool("LEAP_IGNORECASE", opts.ignorecase)
    opts.smartcase = env_bool("LEAP_SMARTCASE", opts.smartcase)
    local case_sensitive = parse_bool(os.getenv("LEAP_CASE_SENSITIVE"))
    if case_sensitive ~= nil then opts.case_sensitive = case_sensitive end
end

local function utf8_len_from_byte(b)
    if not b then return 0 end
    if b < 0x80 then return 1 end
    if b < 0xE0 then return 2 end
    if b < 0xF0 then return 3 end
    return 4
end

local function split_chars(s)
    local chars, i = {}, 1
    while i <= #s do
        local len = utf8_len_from_byte(s:byte(i))
        chars[#chars + 1] = s:sub(i, i + len - 1)
        i = i + len
    end
    return chars
end

local function visual_width(s)
    return #split_chars(s or "")
end

local function strpart_chars(chars, i)
    return chars[i] or ""
end

local function list_contains(t, v)
    if type(t) == "string" then return t == v end
    for _, x in ipairs(t or {}) do
        if x == v then return true end
    end
    return false
end

-- ── terminal/string helpers ─────────────────────────────────────────────────

local function strip_ansi(s)
    s = s:gsub("\027%[[%d%;%:%?%>%<%=]*[%a%@%`%~]", "") -- CSI sequences
    s = s:gsub("\027[P%]X%^_][^\007]*\007", "")          -- DCS/OSC/APC … BEL
    s = s:gsub("\027[P%]X%^_][^\027]*\027\\", "")        -- DCS/OSC/APC … ST
    s = s:gsub("\027.", "")                               -- 2-char ESC sequences
    return s
end

local function expand_tabs(s, tabsize)
    tabsize = tabsize or 8
    local out, col = {}, 0
    for _, c in ipairs(split_chars(s)) do
        if c == "\t" then
            local spaces = tabsize - (col % tabsize)
            out[#out + 1] = string.rep(" ", spaces)
            col = col + spaces
        else
            out[#out + 1] = c
            col = col + 1
        end
    end
    return table.concat(out)
end

-- Like expand_tabs(), but preserves ANSI escapes and does not count them as
-- screen cells while calculating tab stops.
local function expand_tabs_ansi(s, tabsize)
    tabsize = tabsize or 8
    local out, col, i = {}, 0, 1
    while i <= #s do
        local ch = s:sub(i, i)
        if ch == "\027" then
            local nxt = s:sub(i + 1, i + 1)
            local j = i + 1
            if nxt == "[" then
                j = i + 2
                while j <= #s do
                    local b = s:byte(j)
                    if b and b >= 0x40 and b <= 0x7E then break end
                    j = j + 1
                end
            elseif nxt == "]" or nxt == "P" or nxt == "^" or nxt == "_" or nxt == "X" then
                local bel = s:find("\007", i + 2, true)
                local st = s:find("\027\\", i + 2, true)
                if bel and st then j = min(bel, st + 1)
                elseif bel then j = bel
                elseif st then j = st + 1
                else j = i + 1 end
            end
            out[#out + 1] = s:sub(i, j)
            i = j + 1
        else
            local len = utf8_len_from_byte(s:byte(i))
            local c = s:sub(i, i + len - 1)
            if c == "\t" then
                local spaces = tabsize - (col % tabsize)
                out[#out + 1] = string.rep(" ", spaces)
                col = col + spaces
            else
                out[#out + 1] = c
                col = col + 1
            end
            i = i + len
        end
    end
    return table.concat(out)
end

local function at(row, col)
    return string.format("\027[%d;%dH", row + 1, col + 1)
end

local function render_content(lines, width, height)
    io.write("\027[H")
    for row = 1, height do
        local expanded = expand_tabs_ansi(lines[row] or "")
        local plain = strip_ansi(expanded)
        local padding = max(0, width - visual_width(plain))
        io.write(expanded .. string.rep(" ", padding) .. RESET)
        if row < height then io.write("\r\n") end
    end
end

local function read_char()
    local c = io.read(1)
    if not c then return nil end
    local b = c:byte(1)
    if not b or b < 0x80 then return c end
    local len = utf8_len_from_byte(b)
    if len <= 1 then return c end
    return c .. (io.read(len - 1) or "")
end

local function is_cancel(ch)
    return (not ch) or ch == "\027" or ch == "\003" or ch == "\004"
end

-- ── leap.nvim equivalence/case helpers (adapted from main.lua) ──────────────

local function to_membership_lookup(eqv_classes)
    local res = {}
    for _, cl in ipairs(eqv_classes) do
        local cl_2a = split_chars(cl)
        for _, ch in ipairs(cl_2a) do
            res[ch] = cl_2a
        end
    end
    return res
end

local function has_upper(s)
    return s and s:lower() ~= s
end

local function effective_case_sensitive(in1, in2)
    if opts.case_sensitive ~= nil then return opts.case_sensitive end
    if not opts.ignorecase then return true end
    if opts.smartcase and (has_upper(in1) or has_upper(in2)) then return true end
    return false
end

local function norm(ch, case_sensitive)
    if ch == "" then ch = "\n" end
    if not ch then return nil end
    if case_sensitive then return ch end
    return ch:lower()
end

local function get_equivalence_class(ch, consider_smartcase, case_sensitive)
    if ch == "" then ch = "\n" end
    if (case_sensitive or (consider_smartcase and opts.smartcase and has_upper(ch))) then
        return opts.eqv_class_of[ch]
    else
        return opts.eqv_class_of[ch:lower()] or opts.eqv_class_of[ch:upper()]
    end
end

local function get_representative_char(ch, case_sensitive)
    if ch == "" then ch = "\n" end
    local cl = get_equivalence_class(ch, false, case_sensitive)
    local ch_2a = (cl and cl[1]) or ch
    if case_sensitive then return ch_2a end
    return ch_2a:lower()
end

local function char_matches(input, target, case_sensitive)
    if not input or not target then return false end
    if target == "" then target = "\n" end
    if input == "" then input = "\n" end
    local class = get_equivalence_class(input, true, case_sensitive)
    if class then
        local nt = norm(target, case_sensitive)
        for _, ch in ipairs(class) do
            if norm(ch, case_sensitive) == nt then return true end
        end
        return false
    end
    return norm(input, case_sensitive) == norm(target, case_sensitive)
end

local function same_input_class(in1, in2, case_sensitive)
    return char_matches(in1, in2, case_sensitive) and char_matches(in2, in1, case_sensitive)
end

-- ── target search/ranking (adapted from search.lua) ─────────────────────────

local function make_plain_lines(lines)
    local plain = {}
    for i, line in ipairs(lines) do
        plain[i] = expand_tabs(strip_ansi(line))
    end
    return plain
end

local function collect_targets(lines, width)
    local targets = {}
    local plain_lines = make_plain_lines(lines)
    for row0, line in ipairs(plain_lines) do
        local row = row0 - 1
        local chars = split_chars(line)
        if #chars == 0 then
            targets[#targets + 1] = {
                row = row,
                vcol = 0,
                pos = {row + 1, 1},
                chars = {"", ""},
                logical = {"\n", "\n"},
                prev = nil,
                wininfo = {winid = 1, bufnr = 1},
            }
        else
            for i, ch1 in ipairs(chars) do
                local col = i - 1
                if col < width then
                    local ch2 = strpart_chars(chars, i + 1)
                    targets[#targets + 1] = {
                        row = row,
                        vcol = col,
                        pos = {row + 1, col + 1},
                        chars = {ch1, ch2},
                        logical = {ch1, (ch2 ~= "" and ch2 or "\n")},
                        prev = chars[i - 1],
                        ["win-edge?"] = (col >= width - 1),
                        wininfo = {winid = 1, bufnr = 1},
                    }
                end
            end
        end
    end
    return targets
end

local function target_matches_input(target, in1, in2)
    local case_sensitive = effective_case_sensitive(in1, in2)
    if not char_matches(in1, target.logical[1], case_sensitive) then return false end

    if in2 then
        if not char_matches(in2, target.logical[2], case_sensitive) then return false end
        -- Leap's same-character pattern matches a run only at its beginning:
        --    \(^\|[^a]\)\zsaa
        if same_input_class(in1, in2, case_sensitive) and
           char_matches(in1, target.prev, case_sensitive) then
            return false
        end
        return true
    end

    -- Preview pattern copied conceptually from leap.nvim's prepare_pattern():
    -- show the first char of a same-char run and the char before a non-match,
    -- but do not label the middle of repeated same-char sequences.
    if char_matches(in1, target.logical[2], case_sensitive) and
       char_matches(in1, target.prev, case_sensitive) then
        return false
    end
    return true
end

local function euclidean_distance(p1, p2)
    local l1, c1 = p1[1], p1[2]
    local l2, c2 = p2[1], p2[2]
    local editor_grid_aspect_ratio = 0.3
    local dx = abs(c1 - c2) * editor_grid_aspect_ratio
    local dy = abs(l1 - l2)
    return sqrt((dx * dx) + (dy * dy))
end

local function rank(targets, cursor)
    local cur_pos = {cursor.row + 1, cursor.col + 1}
    for _, target in ipairs(targets) do
        local line = target.pos[1]
        local col = target.pos[2]
        local distance = euclidean_distance(target.pos, cur_pos)
        local curr_win_bonus = 30
        local curr_line_bonus = (line == cur_pos[1]) and 999 or nil
        local curr_line_fwd_bonus = (curr_line_bonus and (col > cur_pos[2])) and 999 or nil
        target.rank = distance - curr_win_bonus - (curr_line_bonus or 0) - (curr_line_fwd_bonus or 0)
    end
end

local function find_targets(lines, in1, in2, width, cursor)
    local all = collect_targets(lines, width)
    local targets = {}
    for _, target in ipairs(all) do
        local at_cursor = target.row == cursor.row and target.vcol == cursor.col
        if (not at_cursor) and target_matches_input(target, in1, in2) then
            targets[#targets + 1] = target
        end
    end
    if #targets == 0 then return nil end
    rank(targets, cursor)
    table.sort(targets, function(a, b)
        if a.rank == b.rank then
            if a.row == b.row then return a.vcol < b.vcol end
            return a.row < b.row
        end
        return a.rank < b.rank
    end)
    return targets
end

-- ── label/group logic copied/adapted from leap.nvim/lua/leap/main.lua ───────

local function populate_sublists(targets, in1)
    local case_sensitive = effective_case_sensitive(in1, nil)
    targets.sublists = {}
    for _, target in ipairs(targets) do
        local ch1, ch2 = target.chars[1], target.chars[2]
        local key
        if ((ch1 == "") or (ch2 == "")) then
            key = "\n"
        else
            key = get_representative_char(ch2, case_sensitive)
        end
        if not targets.sublists[key] then targets.sublists[key] = {} end
        table.insert(targets.sublists[key], target)
    end
end

local function as_traversable(labels, first_offscreen_3f)
    if (#labels == 0) then
        return labels
    else
        local bad_keys = ""
        for _, key in ipairs({opts.keys.next_target, opts.keys.prev_target}) do
            if type(key) == "table" then
                bad_keys = bad_keys .. table.concat(key)
            else
                bad_keys = bad_keys .. key
            end
        end
        local sanitized = labels:gsub(("[" .. bad_keys:gsub("%W", "%%%0") .. "]"), "")
        local next_key = ((type(opts.keys.next_target) == "table") and opts.keys.next_target[2])
        if (next_key and string.match(next_key, "%S") and not first_offscreen_3f) then
            return (next_key .. sanitized)
        else
            return sanitized
        end
    end
end

local function prepare_labeled_targets(targets, kwargs)
    kwargs = kwargs or {}
    local can_traverse_3f = kwargs["can-traverse?"]
    local force_noautojump_3f = kwargs["force-noautojump?"]
    local multi_window_3f = kwargs["multi-window?"]

    local function all_in_the_same_window_3f(targets0)
        local same_win_3f = true
        local win = targets0[1].wininfo.winid
        for _, target in ipairs(targets0) do
            if same_win_3f == false then break end
            if target.wininfo.winid ~= win then same_win_3f = false end
        end
        return same_win_3f
    end

    local function first_covers_label_of_second_3f(targets0)
        local t1, t2 = targets0[1], targets0[2]
        if (t2 and t2.chars and not t2["offscreen?"]) then
            local line1, col1 = t1.pos[1], t1.pos[2]
            local line2, col2 = t2.pos[1], t2.pos[2]
            return ((line1 == line2) and
                    (col1 == (col2 + visual_width(table.concat(t2.chars)))))
        end
        return nil
    end

    local function first_offscreen_3f(targets0)
        return ((#targets0 > 1) and targets0[1]["offscreen?"])
    end

    local labels, safe_labels
    if can_traverse_3f then
        labels = as_traversable(opts.labels, first_offscreen_3f(targets))
        safe_labels = as_traversable(opts.safe_labels, first_offscreen_3f(targets))
    else
        labels = opts.labels
        safe_labels = opts.safe_labels
    end

    local labels0 = split_chars(labels)
    local safe_labels0 = split_chars(safe_labels)

    local function enough_safe_labels_3f(targets0)
        local limit = (#safe_labels0 + 1)
        local count = 0
        for _, t in ipairs(targets0) do
            if count > limit then break end
            if not t["offscreen?"] then count = count + 1 end
        end
        return (count <= limit)
    end

    local function set_autojump(targets0)
        if not (force_noautojump_3f or
                (multi_window_3f and not all_in_the_same_window_3f(targets0)) or
                first_offscreen_3f(targets0) or
                first_covers_label_of_second_3f(targets0) or
                (#safe_labels0 == 0)) then
            targets0["autojump?"] = ((#labels0 == 0) or enough_safe_labels_3f(targets0))
        end
    end

    local function attach_label_set(targets0)
        if (#labels0 == 0) then
            targets0["label-set"] = safe_labels0
        elseif (#safe_labels0 == 0) then
            targets0["label-set"] = labels0
        elseif targets0["autojump?"] then
            targets0["label-set"] = safe_labels0
        else
            targets0["label-set"] = labels0
        end
    end

    local function set_labels(targets0)
        local autojump_3f = targets0["autojump?"]
        local labels1 = targets0["label-set"]
        local labels_len = #labels1
        if labels_len == 0 then return end
        local skipped = autojump_3f and 1 or 0
        for i = (skipped + 1), #targets0 do
            local target = targets0[i]
            if target then
                local i_2a = (i - skipped)
                if target["offscreen?"] then
                    skipped = skipped + 1
                else
                    local n = i_2a % labels_len
                    if n == 0 then
                        target.label = labels1[labels_len]
                        target.group = floor(i_2a / labels_len)
                    else
                        target.label = labels1[n]
                        target.group = floor(i_2a / labels_len) + 1
                    end
                end
            end
        end
    end

    set_autojump(targets)
    attach_label_set(targets)
    set_labels(targets)
end

-- ── beacon logic copied/adapted from leap.nvim/lua/leap/beacons.lua ─────────

local function get_label_offset(target)
    local ch1, ch2 = target.chars[1], target.chars[2]
    local ch2_width
    if target["win-edge?"] then ch2_width = 0 else ch2_width = visual_width(ch2) end
    return visual_width(ch1) + ch2_width
end

local function set_beacon_for_labeled(target, group_offset, phase)
    local offset
    if (target.chars and phase) then
        offset = get_label_offset(target)
    else
        offset = 0
    end
    local has_ch2_3f = (target.chars and (target.chars[2] ~= ""))
    local pad = (has_ch2_3f and not phase) and " " or ""
    local label = (opts.substitute_chars[target.label] or target.label)
    local relative_group = (target.group - (group_offset or 0))
    local vtext
    if (relative_group == 1) then
        vtext = {{(label .. pad), hl.group.label}}
    elseif (relative_group == 2) then
        vtext = {{(opts.concealed_label .. pad), hl.group["label-dimmed"]}}
    elseif ((relative_group > 2) and phase) then
        vtext = {{(opts.concealed_label .. pad), hl.group["label-dimmed"]}}
    else
        vtext = nil
    end
    if vtext then
        target.beacon = {offset, {virt_text = vtext}}
    else
        target.beacon = nil
    end
end

local function set_beacons(targets, kwargs)
    kwargs = kwargs or {}
    local group_offset = kwargs["group-offset"]
    local phase = kwargs.phase
    for _, target in ipairs(targets) do
        if target.label then
            set_beacon_for_labeled(target, group_offset, phase)
        else
            target.beacon = nil
        end
    end
end

local function beacon_col(target, width)
    local col = target.vcol + (target.beacon and target.beacon[1] or 0)
    return clamp(col, 0, max(0, width - 1))
end

local function resolve_conflicts(targets, width)
    local function set_beacon_to_concealed_label(target)
        if target.beacon and target.beacon[2] and target.beacon[2].virt_text then
            target.beacon[2].virt_text[1][1] = opts.concealed_label
        end
    end

    local unlabeled_match_positions = {}
    local label_positions = {}
    for _, target in ipairs(targets) do
        local empty_line_3f = ((target.chars[1] == "") and (target.pos[2] == 1))
        if not empty_line_3f then
            local row = target.row
            local col_ch1 = target.vcol
            local col_ch2 = col_ch1 + visual_width(target.chars[1])
            local key_prefix = row .. " "
            if (target.label and target.beacon) then
                local col_label = beacon_col(target, width)
                local shifted_label_3f = (col_label == col_ch2)
                local other = label_positions[key_prefix .. col_label]
                if (not other) and shifted_label_3f then
                    other = unlabeled_match_positions[key_prefix .. col_ch1]
                end
                if not other then
                    other = unlabeled_match_positions[key_prefix .. col_label]
                end
                if other then
                    other.beacon = nil
                    set_beacon_to_concealed_label(target)
                end
                label_positions[key_prefix .. col_label] = target
            else
                local col_ch3 = col_ch2 + visual_width(target.chars[2])
                local other = label_positions[key_prefix .. col_ch1] or
                              label_positions[key_prefix .. col_ch2] or
                              label_positions[key_prefix .. col_ch3]
                if other then
                    target.beacon = nil
                    set_beacon_to_concealed_label(other)
                end
                unlabeled_match_positions[key_prefix .. col_ch1] = target
                unlabeled_match_positions[key_prefix .. col_ch2] = target
            end
        end
    end
end

local function light_up_beacons(targets, width)
    for _, target in ipairs(targets) do
        if target.beacon then
            local vtext = target.beacon[2].virt_text
            if vtext and vtext[1] then
                local text, group = vtext[1][1], vtext[1][2]
                local col = beacon_col(target, width)
                io.write(at(target.row, col) .. (STYLE[group] or "") .. text .. RESET)
            end
        end
    end
end

-- ── popup control flow ──────────────────────────────────────────────────────

local indicator_chars = {nil, nil}

local function indicator_char(ch)
    if not ch then return "" end
    if ch == " " then return "␠" end
    if ch == "\t" then return "⇥" end
    if ch == "\r" or ch == "\n" then return "↵" end
    if ch == "\127" or ch == "\8" then return "⌫" end
    return ch
end

local function render_indicator(width)
    local text = "jump: " .. indicator_char(indicator_chars[1]) .. indicator_char(indicator_chars[2]) .. " "
    text = text .. string.rep(" ", max(0, 9 - visual_width(text)))
    local col = max(0, width - visual_width(text))
    io.write(at(0, col) .. INDICATOR .. text .. RESET)
end

local function parse_lines(raw, height)
    local lines = {}
    for line in raw:gmatch("([^\n]*)\n") do
        lines[#lines + 1] = line
    end
    if raw ~= "" and raw:sub(-1) ~= "\n" then
        lines[#lines + 1] = raw:match("[^\n]*$") or ""
    end
    while #lines < height do lines[#lines + 1] = "" end
    for i = height + 1, #lines do lines[i] = nil end
    return lines
end

local function draw(lines, width, height, targets, phase, group_offset)
    render_content(lines, width, height)
    if targets then
        set_beacons(targets, {phase = phase, ["group-offset"] = group_offset})
        resolve_conflicts(targets, width)
        light_up_beacons(targets, width)
    end
    render_indicator(width)
    io.flush()
end

local function get_target_with_active_label(targets, input, group_offset)
    for _, target in ipairs(targets) do
        if target.label then
            local relative_group = target.group - (group_offset or 0)
            if relative_group > 1 then return nil end
            if relative_group == 1 and target.label == input then return target end
        end
    end
    return nil
end

local function active_label_group_count(targets)
    local label_set = targets["label-set"] or {}
    if #label_set == 0 then return 0 end

    local labeled = 0
    for _, target in ipairs(targets) do
        if target.label then labeled = labeled + 1 end
    end
    return ceil(labeled / #label_set)
end

local function write_result(result_file, target)
    local out = io.open(result_file, "w")
    if out then
        out:write(target.row .. ":" .. target.vcol .. "\n")
        out:close()
    end
end

local function select_target(lines, width, height, result_file, targets)
    prepare_labeled_targets(targets, {
        ["can-traverse?"] = false,
        ["force-noautojump?"] = false,
        ["multi-window?"] = false,
    })

    if targets["autojump?"] and #targets == 1 then
        write_result(result_file, targets[1])
        return
    end

    local groups = active_label_group_count(targets)
    local group_offset = 0

    while true do
        draw(lines, width, height, targets, 2, group_offset)
        local input = read_char()
        if is_cancel(input) then return end

        if list_contains(opts.keys.next_target, input) then
            write_result(result_file, targets[1])
            return
        elseif list_contains(opts.keys.next_group, input) and groups > 1 then
            group_offset = clamp(group_offset + 1, 0, groups - 1)
        elseif list_contains(opts.keys.prev_group, input) and groups > 1 then
            group_offset = clamp(group_offset - 1, 0, groups - 1)
        else
            local target = get_target_with_active_label(targets, input, group_offset)
            if target then
                write_result(result_file, target)
            end
            return
        end
    end
end

local function run()
    load_opts_from_env()
    opts.eqv_class_of = to_membership_lookup(opts.equivalence_classes)

    local content_file = os.getenv("CONTENT_FILE") or ""
    local result_file  = os.getenv("RESULT_FILE")  or ""
    local height = tonumber(os.getenv("PANE_HEIGHT")) or 24
    local width  = tonumber(os.getenv("PANE_WIDTH"))  or 80
    local cursor = {
        row = clamp(tonumber(os.getenv("CURSOR_ROW")) or (height - 1), 0, height - 1),
        col = clamp(tonumber(os.getenv("CURSOR_COL")) or 0, 0, width - 1),
    }

    local f = io.open(content_file, "r")
    if not f then os.exit(1) end
    local raw = f:read("*a")
    f:close()

    local lines = parse_lines(raw, height)

    if os.getenv("LEAP_PREPAINTED") ~= "1" then
        draw(lines, width, height)
    else
        render_indicator(width)
        io.flush()
    end

    -- char 1: preview all possible pairs, exactly like leap.nvim's phase 1.
    local in1 = read_char()
    if is_cancel(in1) or list_contains(opts.keys.next_target, in1) then return end

    indicator_chars[1] = in1

    local targets = find_targets(lines, in1, nil, width, cursor)
    if not targets then return end

    populate_sublists(targets, in1)
    for _, sublist in pairs(targets.sublists) do
        prepare_labeled_targets(sublist, {
            ["can-traverse?"] = false,
            ["force-noautojump?"] = false,
            ["multi-window?"] = false,
        })
        set_beacons(sublist, {phase = 1, ["group-offset"] = 0})
    end
    resolve_conflicts(targets, width)
    render_content(lines, width, height)
    light_up_beacons(targets, width)
    render_indicator(width)
    io.flush()

    -- char 2: filter the already-ranked phase-1 target set.
    local in2 = read_char()
    if is_cancel(in2) then return end

    if list_contains(opts.keys.next_target, in2) then
        write_result(result_file, targets[1])
        return
    end

    indicator_chars[2] = in2

    local targets2 = {}
    for _, target in ipairs(targets) do
        if target_matches_input(target, in1, in2) then
            targets2[#targets2 + 1] = target
        end
    end
    if #targets2 == 0 then return end

    select_target(lines, width, height, result_file, targets2)
end

local function main()
    local saved_stty = nil
    do
        local p = io.popen("stty -g 2>/dev/null")
        if p then
            saved_stty = p:read("*l")
            p:close()
        end
    end

    io.write(HIDE)
    io.flush()
    os.execute("stty raw -echo 2>/dev/null")

    local ok = pcall(run)

    if saved_stty and saved_stty ~= "" then
        os.execute("stty " .. saved_stty .. " 2>/dev/null")
    else
        os.execute("stty sane 2>/dev/null")
    end
    io.write(SHOW)
    io.flush()

    if not ok then os.exit(1) end
end

main()
