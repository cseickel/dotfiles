--[[
Which key runs which action.

Kept apart from both the actions and the setup so the help panel can read it
without either depending on the other. `map` is replaced wholesale when the
user passes their own table to `setup`.
]]

local M = {}

---@type table<string, string>
M.map = {
  ["<Tab>"] = "next_column",
  ["<S-Tab>"] = "prev_column",

  ["sa"] = "sort_asc",
  ["sd"] = "sort_desc",
  ["Sa"] = "add_sort_key_asc",
  ["Sd"] = "add_sort_key_desc",
  ["ss"] = "remove_sort_key",
  ["sc"] = "clear_sort",

  ["h"] = "hide_column",
  ["x"] = "cut_column",
  ["X"] = "cut_append_column",
  ["p"] = "paste_columns_after",
  ["P"] = "paste_columns_before",
  ["<"] = "move_column_left",
  [">"] = "move_column_right",
  ["<leader>X"] = "show_all_columns",

  ["m"] = "toggle_mark_row",
  ["<M-m>"] = "toggle_mark_column",
  ["M"] = "clear_marks",
  ["fr"] = "filter_to_marked_rows",
  ["fc"] = "filter_to_marked_columns",
  ["fm"] = "filter_to_marked_both",

  ["f"] = "filter",
  ["<BS>"] = "pop_filter",
  ["<leader>fc"] = "clear_filters",

  ["al"] = "align_left",
  ["ac"] = "align_center",
  ["ar"] = "align_right",
  ["."] = "increase_precision",
  [","] = "decrease_precision",
  ["+"] = "increase_width",
  ["_"] = "decrease_width",
  ["@"] = "set_format",

  ["]"] = "next_page",
  ["["] = "prev_page",
  ["]]"] = "last_page",
  ["[["] = "first_page",
  ["<leader>ps"] = "set_page_size",

  ["gs"] = "show_stats",
  ["gi"] = "show_info",
  ["gS"] = "show_sheets",
  ["?"] = "show_help",

  ["<leader>r"] = "refresh",
  ["<leader>x"] = "clear_all",
}

return M
