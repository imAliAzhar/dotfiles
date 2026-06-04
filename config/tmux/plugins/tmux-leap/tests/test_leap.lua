#!/usr/bin/env luajit
-- tmux-leap test suite

package.path = ((arg and arg[0] and arg[0]:match("(.*/)") or "./") .. "?.lua;") .. package.path

local fn = require("harness")
local strip_ansi              = fn.strip_ansi
local expand_tabs             = fn.expand_tabs
local find_targets            = fn.find_targets
local prepare_labeled_targets = fn.prepare_labeled_targets
local set_beacons             = fn.set_beacons
local get_label_offset        = fn.get_label_offset
local active_label_group_count = fn.active_label_group_count
local split_chars             = fn.split_chars
local at                      = fn.at
local opts                    = fn.opts
local DEFAULT_LABELS          = fn.DEFAULT_LABELS
local DEFAULT_SAFE_LABELS     = fn.DEFAULT_SAFE_LABELS

-- ── mini test harness ─────────────────────────────────────────────────────────

local pass, fail = 0, 0
local failures = {}
local current_suite = ""

local function suite(name) current_suite = name end

local function eq(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table"  then return a == b end
    for k, v in pairs(a) do
        if not eq(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

local function fmt(v)
    if type(v) == "string" then return string.format("%q", v) end
    if type(v) == "table" then
        local parts = {}
        for k, x in pairs(v) do
            parts[#parts + 1] = tostring(k) .. "=" .. fmt(x)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(v)
end

local function check(name, got, want)
    if eq(got, want) then
        pass = pass + 1
    else
        fail = fail + 1
        failures[#failures + 1] = string.format(
            "  FAIL [%s] %s\n       got  %s\n       want %s",
            current_suite, name, fmt(got), fmt(want))
    end
end

-- ── strip_ansi ────────────────────────────────────────────────────────────────

suite("strip_ansi")

check("plain text unchanged",
    strip_ansi("hello world"), "hello world")
check("SGR color code",
    strip_ansi("\027[38;5;214mhello\027[0m"), "hello")
check("bold + color",
    strip_ansi("\027[1m\027[32mtext\027[0m"), "text")
check("CSI with ? param (hide cursor)",
    strip_ansi("a\027[?25lb"), "ab")
check("CSI with ? param (show cursor)",
    strip_ansi("a\027[?25hb"), "ab")
check("CSI with > param",
    strip_ansi("a\027[>1hb"), "ab")
check("OSC terminated by BEL",
    strip_ansi("a\027]0;my title\007b"), "ab")
check("OSC terminated by ST",
    strip_ansi("a\027]0;title\027\\b"), "ab")
check("APC sequence (kitty image protocol)",
    strip_ansi("a\027_Ga=t,f=32;\027\\b"), "ab")
check("DCS sequence",
    strip_ansi("a\027Psome data\027\\b"), "ab")
check("2-char ESC sequence",
    strip_ansi("a\027Mb"), "ab")
check("multiple sequences in one string",
    strip_ansi("\027[32mfoo\027[0m \027[1mbar\027[0m"), "foo bar")
check("nested content preserved",
    strip_ansi("\027[38;5;220m\027[1mX\027[0mYZ"), "XYZ")
check("empty string",
    strip_ansi(""), "")
check("no sequences",
    strip_ansi("no escapes here"), "no escapes here")

-- ── expand_tabs ───────────────────────────────────────────────────────────────

suite("expand_tabs")

check("tab at col 0 → 8 spaces",
    expand_tabs("\t"), "        ")
check("tab at col 4 → 4 spaces",
    expand_tabs("abcd\t"), "abcd    ")
check("tab at col 8 → 8 spaces (next stop)",
    expand_tabs("12345678\t"), "12345678        ")
check("two consecutive tabs from col 0",
    expand_tabs("\t\t"), "                ")
check("tab after text",
    expand_tabs("foo\tbar"), "foo     bar")
check("no tabs unchanged",
    expand_tabs("hello"), "hello")
check("empty string",
    expand_tabs(""), "")
check("custom tabsize 4",
    expand_tabs("\t", 4), "    ")
check("custom tabsize 4 at col 2",
    expand_tabs("ab\t", 4), "ab  ")

-- ── leap.nvim labels / target preparation ────────────────────────────────────

suite("leap labels")

local label_chars = split_chars(DEFAULT_LABELS)
local blen = #label_chars

check("default labels copied from leap.nvim",
    DEFAULT_LABELS,
    "sfnjklhodweimbuyvrgtaqpcxz/SFNJKLHODWEIMBUYVRGTAQPCXZ?")

check("safe labels default to the dotfiles' Neovim override",
    DEFAULT_SAFE_LABELS, "")

local function fake_targets(n)
    local ts = {}
    for i = 1, n do
        ts[i] = {
            row = 0,
            vcol = i - 1,
            pos = {1, i},
            chars = {"a", "b"},
            wininfo = {winid = 1, bufnr = 1},
        }
    end
    return ts
end

local ts = fake_targets(blen + 2)
prepare_labeled_targets(ts, {["can-traverse?"] = false})
check("first target gets first Leap label", ts[1].label, "s")
check("last target in first group uses last label", ts[blen].label, "?")
check("overflow starts group 2 with first label", {ts[blen + 1].label, ts[blen + 1].group}, {"s", 2})
check("safe-labels disabled means no autojump", ts["autojump?"], nil)

local saved_safe_labels = opts.safe_labels
opts.safe_labels = "ab"
local autojump_targets = fake_targets(3)
prepare_labeled_targets(autojump_targets, {["can-traverse?"] = false})
check("autojump labels only non-default targets",
    {autojump_targets["autojump?"], autojump_targets[1].label, autojump_targets[2].label, autojump_targets[3].label},
    {true, nil, "a", "b"})
check("autojump group count ignores the unlabeled target",
    active_label_group_count(autojump_targets), 1)
opts.safe_labels = saved_safe_labels

-- ── Leap-style search semantics ──────────────────────────────────────────────

suite("find_targets")

local function simple_targets(targets)
    local out = {}
    for _, t in ipairs(targets or {}) do
        out[#out + 1] = {row = t.row, vcol = t.vcol, chars = t.chars}
    end
    return out
end

check("current cursor position is skipped and current-line-forward ranks first",
    simple_targets(find_targets({"abc abc", "abc"}, "a", "b", 80, {row = 0, col = 0}))[1],
    {row = 0, vcol = 4, chars = {"a", "b"}})

check("same-character pair matches only the start of a run",
    simple_targets(find_targets({"aaaa"}, "a", "a", 80, {row = 9, col = 0})),
    {{row = 0, vcol = 0, chars = {"a", "a"}}})

check("phase-1 preview skips the middle of same-character runs",
    (function()
        local cols = {}
        for _, t in ipairs(find_targets({"aaaa"}, "a", nil, 80, {row = 9, col = 0})) do
            cols[#cols + 1] = t.vcol
        end
        return cols
    end)(), {0, 3})

check("space aliases end-of-line for targeting the last character",
    simple_targets(find_targets({"aaaa"}, "a", " ", 80, {row = 9, col = 0})),
    {{row = 0, vcol = 3, chars = {"a", ""}}})

check("space-space targets an empty line",
    simple_targets(find_targets({""}, " ", " ", 80, {row = 9, col = 0})),
    {{row = 0, vcol = 0, chars = {"", ""}}})

check("ignorecase matches both cases",
    #find_targets({"Foo foo"}, "f", "o", 80, {row = 9, col = 0}), 2)

check("smartcase uppercase input is case-sensitive",
    #find_targets({"Foo foo"}, "F", "o", 80, {row = 9, col = 0}), 1)

local colored = "\027[32mfoo\027[0m bar"
check("ANSI before target: correct vcol",
    simple_targets(find_targets({colored}, "b", "a", 80, {row = 9, col = 0})),
    {{row = 0, vcol = 4, chars = {"b", "a"}}})

local bullet_line = "\xE2\x80\xA2 passing"
check("UTF-8 before target: correct vcol",
    simple_targets(find_targets({bullet_line}, "p", "a", 80, {row = 9, col = 0}))[1].vcol, 2)

local tab_line = "\tfoo"  -- "foo" starts at visual col 8
check("tab before target: correct vcol",
    simple_targets(find_targets({tab_line}, "f", "o", 80, {row = 9, col = 0}))[1].vcol, 8)

-- ── beacons ─────────────────────────────────────────────────────────────────

suite("beacons")

local target = {chars = {"a", "b"}, ["win-edge?"] = false}
check("label offset is after the two-character pair", get_label_offset(target), 2)

target = {chars = {"a", ""}, ["win-edge?"] = false}
check("label offset after EOL target is after char1", get_label_offset(target), 1)

target = {chars = {"a", "b"}, ["win-edge?"] = true}
check("window-edge labels are shifted left like leap.nvim", get_label_offset(target), 1)

local one = fake_targets(1)
prepare_labeled_targets(one, {["can-traverse?"] = false})
set_beacons(one, {phase = 2, ["group-offset"] = 0})
check("phase-2 beacon overlays the active label",
    one[1].beacon[2].virt_text[1], {"s", "LeapLabel"})

-- ── at() ─────────────────────────────────────────────────────────────────────

suite("at")

check("at(0,0) → top-left",       at(0, 0),   "\027[1;1H")
check("at(0,5) → col 6",          at(0, 5),   "\027[1;6H")
check("at(3,0) → row 4",          at(3, 0),   "\027[4;1H")
check("at(23,79) → bottom-right", at(23, 79), "\027[24;80H")

-- ── results ──────────────────────────────────────────────────────────────────

print(string.format("\n%d passed, %d failed, %d total", pass, fail, pass + fail))
if #failures > 0 then
    print("\nFailures:")
    for _, f in ipairs(failures) do print(f) end
    os.exit(1)
end
