-- Test harness: load leap_popup.lua functions without executing main()
-- Returns selected local functions for testing.

local script_path = arg and arg[0] and arg[0]:match("(.*/)")
local plugin_root = script_path and (script_path .. "..") or ".."
local popup_path  = plugin_root .. "/scripts/leap_popup.lua"

local src = assert(io.open(popup_path, "r"), "cannot open " .. popup_path):read("*a")

-- Strip the main() call at the end and the shebang line,
-- then re-expose selected locals via a returned table.
src = src:gsub("^#![^\n]*\n", "")   -- remove shebang
src = src:gsub("\nmain%(%)\n?$", "")  -- remove tail call

src = src .. [[

opts.eqv_class_of = to_membership_lookup(opts.equivalence_classes)

return {
    strip_ansi               = strip_ansi,
    expand_tabs              = expand_tabs,
    find_targets             = find_targets,
    target_matches_input     = target_matches_input,
    populate_sublists        = populate_sublists,
    prepare_labeled_targets  = prepare_labeled_targets,
    set_beacons              = set_beacons,
    get_label_offset         = get_label_offset,
    active_label_group_count = active_label_group_count,
    split_chars              = split_chars,
    at                       = at,
    opts                     = opts,
    DEFAULT_LABELS           = DEFAULT_LABELS,
    DEFAULT_SAFE_LABELS      = DEFAULT_SAFE_LABELS,
}
]]

local chunk, err = load(src, "leap_popup")
assert(chunk, "load failed: " .. tostring(err))
return chunk()
