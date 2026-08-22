--[[
mappings.lua — keymap table for the functions below. Every rhs here is an
action name that already exists in csv.lua's M.actions (a few were added
alongside this file: cut/paste column, mark column, filter-to-marked-
columns/both, sort asc/desc, multi-sort add/remove by direction, align,
precision, format, width, and first/last page).

Usage:

    local csv = require('csv')
    csv.apply_keymaps(bufnr, { keymaps = require('mappings') })

    -- or merge into the defaults instead of replacing them:
    local merged = vim.tbl_extend('force', csv.keymaps, require('mappings'))
    csv.apply_keymaps(bufnr, { keymaps = merged })

Where this table reuses a binding from csv.lua's own M.keymaps (f, x, <, >)
the action is identical, so merging is safe — nothing here contradicts the
defaults, it only adds coverage for functions the defaults didn't have.
]]

return {
  -- column navigation
  ["<Tab>"]   = "next_column",
  ["<S-Tab>"] = "prev_column",
  ["gs"]      = "show_stats_under_cursor",

  -- filter
  ["f"]       = "filter_text_prompt",

  -- move / hide / cut / paste column
  ["<"]       = "move_column_left_under_cursor",
  [">"]       = "move_column_right_under_cursor",
  ["h"]       = "hide_column_under_cursor",
  ["x"]       = "cut_column_under_cursor",
  ["X"]       = "cut_append_column_under_cursor",
  ["p"]       = "paste_columns_after_cursor",
  ["P"]       = "paste_columns_before_cursor",

  -- marking
  ["m"]       = "toggle_mark_row_under_cursor",         -- mark row
  ["<M-m>"]   = "toggle_mark_column_under_cursor",  -- mark column
  ["fr"]      = "filter_to_marked_rows",
  ["fc"]      = "filter_to_marked_columns",
  ["fm"]      = "filter_to_marked_both",

  -- sort
  ["sa"]      = "sort_asc_under_cursor",             -- single-key sort, ascending
  ["sd"]      = "sort_desc_under_cursor",            -- single-key sort, descending
  ["Sa"]      = "add_sort_key_asc_under_cursor",      -- add/update in multi-sort, asc
  ["Sd"]      = "add_sort_key_desc_under_cursor",     -- add/update in multi-sort, desc
  ["ss"]      = "remove_sort_key_under_cursor",       -- remove from multi-sort

  -- display formatting
  ["al"]      = "align_left_under_cursor",
  ["ac"]      = "align_center_under_cursor",
  ["ar"]      = "align_right_under_cursor",
  ["."]       = "increase_precision_under_cursor",
  [","]       = "decrease_precision_under_cursor",
  ["@"]       = "set_format_prompt_under_cursor",     -- prompts for a format string
  ["+"]       = "increase_width_under_cursor",
  ["_"]       = "decrease_width_under_cursor",

  -- paging
  ["<leader>ps"] = "set_page_size_prompt",
  ["]"]       = "next_page",
  ["["]       = "prev_page",
  ["]]"]      = "last_page",
  ["[["]      = "first_page",
}
