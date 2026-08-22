--[[
csv.lua — interface + state layer for the CSV nvim plugin.

This file implements everything EXCEPT the pipeline: building/running the
qsv (or xan/zsv) command chain, rendering the buffer, and resolving the
cursor to a (rowid, column) pair. Those are left as clearly-marked hooks
below. Wire them up and this module is otherwise complete.

In the real module layout this would be lua/csv/init.lua; it's kept as a
single file here since that's what was asked for.

--------------------------------------------------------------------------
CONTRACT — fill these in from your pipeline/render/cursor modules:

  M.on_state_changed(bufnr)
      Called after every state mutation. Wire it to your run/render code:
        M.on_state_changed = function(bufnr)
          require('csv.run').refresh(bufnr)
        end

  M.get_cursor_rowid(bufnr) -> rowid
      Map the cursor's current line to a rowid (source-file row index).

  M.get_cursor_column(bufnr) -> column_name
      Map the cursor's current column position to a column name.

  M.get_source_columns(bufnr) -> { "col1", "col2", ... }
      Full ordered column list for the source file (e.g. from
      `qsv headers`), used to seed st.visible on first hide/move.

Everything else (state shape, actions, keymap table, applying keymaps)
is implemented and usable as-is.
--------------------------------------------------------------------------
]]

local M = {}

-- ==========================================================================
-- State
-- ==========================================================================
-- One state table per buffer. Shape:
--
--   {
--     source   = "path/to/file.csv",
--     filters  = { <filter spec>, ... },      -- ANDed together, in order
--     sort     = { {col=, reverse=}, ... } | nil,
--     page     = 0,
--     page_size = 2000,
--     visible  = { "col1", "col2", ... } | nil,  -- nil = all, source order
--     marked   = { [rowid] = true, ... },
--     journal  = { [col] = { [rowid] = value, ... }, ... },
--     dirty    = false,
--   }
--
-- filter specs:
--   { kind = "text",   col = "okey_tk", pat = "^SPY$" }
--   { kind = "expr",   expr = "tonumber(uClose) > 100" }
--   { kind = "marked" }                          -- at most one; filters to st.marked

local buffer_states = {}

local function default_state()
  return {
    source     = nil,
    filters    = {},
    sort       = nil,
    page       = 0,
    page_size  = 2000,
    visible    = nil,
    marked     = {},          -- rows:    [rowid] = true
    marked_columns = {},      -- columns: [col]   = true
    filtered_to_marked_columns = false,
    column_clipboard = nil,   -- name of a cut column, or nil
    column_format = {},       -- [col] = { align=, precision=, format=, width= }
    journal    = {},
    dirty      = false,
  }
end

--- Get (creating if needed) the state table for a buffer.
function M.get_state(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not buffer_states[bufnr] then
    buffer_states[bufnr] = default_state()
  end
  return buffer_states[bufnr]
end

--- Reset a buffer's state to defaults (keeps `source`) and refresh.
function M.reset_state(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local source = buffer_states[bufnr] and buffer_states[bufnr].source
  buffer_states[bufnr] = default_state()
  buffer_states[bufnr].source = source
  M.on_state_changed(bufnr)
end

--- Drop a buffer's state entirely (e.g. on BufDelete).
function M.forget_state(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  buffer_states[bufnr] = nil
end

-- ==========================================================================
-- Pipeline / render / cursor hooks — REPLACE THESE
-- ==========================================================================

--- Called after any state mutation. No-op until you override it.
function M.on_state_changed(bufnr)
  -- e.g.: require('csv.run').refresh(bufnr)
end

function M.get_cursor_rowid(bufnr)
  error("csv.get_cursor_rowid(bufnr) is not implemented — wire it to your render/cursor module")
end

function M.get_cursor_column(bufnr)
  error("csv.get_cursor_column(bufnr) is not implemented — wire it to your render/cursor module")
end

function M.get_source_columns(bufnr)
  error("csv.get_source_columns(bufnr) is not implemented — wire it to `qsv headers` or cached state")
end

function M.jump_column(bufnr, delta)
  error("csv.jump_column(bufnr, delta) is not implemented — wire it to your render/cursor module")
end

function M.show_column_stats(bufnr, col)
  error("csv.show_column_stats(bufnr, col) is not implemented — wire it to a stats pipeline call (e.g. `qsv stats --select`)")
end

function M.get_page_count(bufnr)
  error("csv.get_page_count(bufnr) is not implemented — wire it to a row-count pipeline call")
end

-- ==========================================================================
-- Actions — each mutates state for one buffer, then calls on_state_changed.
-- Actions come in two flavors:
--   * "explicit" actions take the values they need as arguments, so you
--     can call them from anywhere (tests, other mappings, commands).
--   * "_under_cursor" / "_prompt" wrappers resolve those values from the
--     cursor or from vim.ui.input, and are what the keymap table points at.
-- ==========================================================================

local actions = {}
M.actions = actions

-- ---- filters -------------------------------------------------------------

function actions.add_text_filter(bufnr, col, pat)
  local st = M.get_state(bufnr)
  table.insert(st.filters, { kind = "text", col = col, pat = pat })
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.add_expr_filter(bufnr, expr)
  local st = M.get_state(bufnr)
  table.insert(st.filters, { kind = "expr", expr = expr })
  st.page = 0
  M.on_state_changed(bufnr)
end

--- Toggle "filter to marked rows" on/off (at most one such filter).
function actions.toggle_marked_filter(bufnr)
  local st = M.get_state(bufnr)
  for i, f in ipairs(st.filters) do
    if f.kind == "marked" then
      table.remove(st.filters, i)
      st.page = 0
      M.on_state_changed(bufnr)
      return
    end
  end
  table.insert(st.filters, { kind = "marked" })
  st.page = 0
  M.on_state_changed(bufnr)
end

--- Drop the most recently added filter.
function actions.pop_filter(bufnr)
  local st = M.get_state(bufnr)
  if #st.filters > 0 then
    table.remove(st.filters)
    st.page = 0
    M.on_state_changed(bufnr)
  end
end

function actions.clear_filters(bufnr)
  local st = M.get_state(bufnr)
  st.filters = {}
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.filter_text_prompt(bufnr)
  vim.ui.input({ prompt = "Filter column: " }, function(col)
    if not col or col == "" then return end
    vim.ui.input({ prompt = "Pattern (regex): " }, function(pat)
      if not pat or pat == "" then return end
      actions.add_text_filter(bufnr, col, pat)
    end)
  end)
end

function actions.filter_expr_prompt(bufnr)
  vim.ui.input({ prompt = "Filter expression: " }, function(expr)
    if not expr or expr == "" then return end
    actions.add_expr_filter(bufnr, expr)
  end)
end

-- ---- sort ------------------------------------------------------------

--- Set the sort to a single key. Calling again on the same column flips
--- direction; calling on a new column replaces the whole sort.
function actions.set_sort(bufnr, col)
  local st = M.get_state(bufnr)
  if st.sort and st.sort[1] and st.sort[1].col == col and #st.sort == 1 then
    st.sort[1].reverse = not st.sort[1].reverse
  else
    st.sort = { { col = col, reverse = false } }
  end
  st.page = 0
  M.on_state_changed(bufnr)
end

--- Append a secondary/tertiary sort key.
function actions.add_sort_key(bufnr, col)
  local st = M.get_state(bufnr)
  st.sort = st.sort or {}
  table.insert(st.sort, { col = col, reverse = false })
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.clear_sort(bufnr)
  local st = M.get_state(bufnr)
  st.sort = nil
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.sort_under_cursor(bufnr)
  actions.set_sort(bufnr, M.get_cursor_column(bufnr))
end

function actions.add_sort_key_under_cursor(bufnr)
  actions.add_sort_key(bufnr, M.get_cursor_column(bufnr))
end

--- Replace the whole sort with a single explicit-direction key.
function actions.set_sort_direction(bufnr, col, reverse)
  local st = M.get_state(bufnr)
  st.sort = { { col = col, reverse = reverse } }
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.sort_asc_under_cursor(bufnr)
  actions.set_sort_direction(bufnr, M.get_cursor_column(bufnr), false)
end

function actions.sort_desc_under_cursor(bufnr)
  actions.set_sort_direction(bufnr, M.get_cursor_column(bufnr), true)
end

--- Add (or update) a multi-sort key with an explicit direction.
function actions.add_sort_key_dir(bufnr, col, reverse)
  local st = M.get_state(bufnr)
  st.sort = st.sort or {}
  for _, key in ipairs(st.sort) do
    if key.col == col then
      key.reverse = reverse
      st.page = 0
      M.on_state_changed(bufnr)
      return
    end
  end
  table.insert(st.sort, { col = col, reverse = reverse })
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.add_sort_key_asc_under_cursor(bufnr)
  actions.add_sort_key_dir(bufnr, M.get_cursor_column(bufnr), false)
end

function actions.add_sort_key_desc_under_cursor(bufnr)
  actions.add_sort_key_dir(bufnr, M.get_cursor_column(bufnr), true)
end

--- Remove one column from a multi-sort (as opposed to clear_sort, which
--- drops the whole thing).
function actions.remove_sort_key(bufnr, col)
  local st = M.get_state(bufnr)
  if not st.sort then return end
  for i, key in ipairs(st.sort) do
    if key.col == col then
      table.remove(st.sort, i)
      break
    end
  end
  if #st.sort == 0 then st.sort = nil end
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.remove_sort_key_under_cursor(bufnr)
  actions.remove_sort_key(bufnr, M.get_cursor_column(bufnr))
end

-- ---- columns (select / hide / move) --------------------------------------

local function ensure_visible(st, bufnr)
  if not st.visible then
    st.visible = M.get_source_columns(bufnr)
  end
end

function actions.hide_column(bufnr, col)
  local st = M.get_state(bufnr)
  ensure_visible(st, bufnr)
  for i, c in ipairs(st.visible) do
    if c == col then
      table.remove(st.visible, i)
      break
    end
  end
  M.on_state_changed(bufnr)
end

function actions.hide_column_under_cursor(bufnr)
  actions.hide_column(bufnr, M.get_cursor_column(bufnr))
end

--- Reset to showing every source column, in source order.
function actions.show_all_columns(bufnr)
  local st = M.get_state(bufnr)
  st.visible = nil
  M.on_state_changed(bufnr)
end

--- Move a column left/right by `delta` positions (e.g. -1 or 1).
function actions.move_column(bufnr, col, delta)
  local st = M.get_state(bufnr)
  ensure_visible(st, bufnr)
  local idx
  for i, c in ipairs(st.visible) do
    if c == col then idx = i break end
  end
  if not idx then return end
  local new_idx = idx + delta
  if new_idx < 1 or new_idx > #st.visible then return end
  st.visible[idx], st.visible[new_idx] = st.visible[new_idx], st.visible[idx]
  M.on_state_changed(bufnr)
end

--- Move a column to an arbitrary 1-based index.
function actions.move_column_to(bufnr, col, index)
  local st = M.get_state(bufnr)
  ensure_visible(st, bufnr)
  local idx
  for i, c in ipairs(st.visible) do
    if c == col then idx = i break end
  end
  if not idx then return end
  index = math.max(1, math.min(index, #st.visible))
  table.remove(st.visible, idx)
  table.insert(st.visible, index, col)
  M.on_state_changed(bufnr)
end

function actions.move_column_left_under_cursor(bufnr)
  actions.move_column(bufnr, M.get_cursor_column(bufnr), -1)
end

function actions.move_column_right_under_cursor(bufnr)
  actions.move_column(bufnr, M.get_cursor_column(bufnr), 1)
end

--- Cut: hide the column and remember it so it can be pasted elsewhere.
function actions.cut_column_under_cursor(bufnr)
  local st = M.get_state(bufnr)
  local col = M.get_cursor_column(bufnr)
  st.column_clipboard = col
  actions.hide_column(bufnr, col)
end

--- Paste: reinsert the cut column just before the column under the cursor
--- (or at the end, if the cursor is past the last visible column).
function actions.paste_column_at_cursor(bufnr)
  local st = M.get_state(bufnr)
  if not st.column_clipboard then return end
  ensure_visible(st, bufnr)
  local at = M.get_cursor_column(bufnr)
  local idx
  for i, c in ipairs(st.visible) do
    if c == at then idx = i break end
  end
  table.insert(st.visible, idx or (#st.visible + 1), st.column_clipboard)
  st.column_clipboard = nil
  M.on_state_changed(bufnr)
end

-- ---- column navigation / stats --------------------------------------

function actions.next_column(bufnr)
  M.jump_column(bufnr, 1)
end

function actions.prev_column(bufnr)
  M.jump_column(bufnr, -1)
end

function actions.show_stats_under_cursor(bufnr)
  M.show_column_stats(bufnr, M.get_cursor_column(bufnr))
end

-- ---- marks -----------------------------------------------------------

function actions.toggle_mark(bufnr, rowid)
  local st = M.get_state(bufnr)
  if st.marked[rowid] then
    st.marked[rowid] = nil
  else
    st.marked[rowid] = true
  end
  M.on_state_changed(bufnr)
end

function actions.toggle_mark_under_cursor(bufnr)
  actions.toggle_mark(bufnr, M.get_cursor_rowid(bufnr))
end

function actions.clear_marks(bufnr)
  local st = M.get_state(bufnr)
  st.marked = {}
  M.on_state_changed(bufnr)
end

function actions.toggle_mark_column(bufnr, col)
  local st = M.get_state(bufnr)
  if st.marked_columns[col] then
    st.marked_columns[col] = nil
  else
    st.marked_columns[col] = true
  end
  M.on_state_changed(bufnr)
end

function actions.toggle_mark_column_under_cursor(bufnr)
  actions.toggle_mark_column(bufnr, M.get_cursor_column(bufnr))
end

function actions.clear_marked_columns(bufnr)
  local st = M.get_state(bufnr)
  st.marked_columns = {}
  M.on_state_changed(bufnr)
end

--- Toggle a filter restricting rows to the marked set (alias kept for the
--- name used elsewhere: "marked rows" == the `marked` filter kind).
function actions.filter_to_marked_rows(bufnr)
  actions.toggle_marked_filter(bufnr)
end

--- Toggle restricting the visible columns to just the marked ones.
function actions.filter_to_marked_columns(bufnr)
  local st = M.get_state(bufnr)
  if st.filtered_to_marked_columns then
    st.visible = nil
    st.filtered_to_marked_columns = false
  else
    local cols = {}
    for _, c in ipairs(M.get_source_columns(bufnr)) do
      if st.marked_columns[c] then table.insert(cols, c) end
    end
    st.visible = cols
    st.filtered_to_marked_columns = true
  end
  M.on_state_changed(bufnr)
end

--- Apply both restrictions at once: marked rows AND marked columns only.
function actions.filter_to_marked_both(bufnr)
  actions.filter_to_marked_columns(bufnr)
  actions.filter_to_marked_rows(bufnr)
end

-- ---- column display formatting (align / precision / format / width) ------

local function ensure_format(st, col)
  st.column_format[col] = st.column_format[col] or {}
  return st.column_format[col]
end

function actions.set_align(bufnr, col, align)
  local st = M.get_state(bufnr)
  ensure_format(st, col).align = align
  M.on_state_changed(bufnr)
end

function actions.align_left_under_cursor(bufnr)
  actions.set_align(bufnr, M.get_cursor_column(bufnr), "left")
end

function actions.align_center_under_cursor(bufnr)
  actions.set_align(bufnr, M.get_cursor_column(bufnr), "center")
end

function actions.align_right_under_cursor(bufnr)
  actions.set_align(bufnr, M.get_cursor_column(bufnr), "right")
end

--- Nudge decimal precision up/down (floored at 0), e.g. for a `--significance`
--- style flag on a formatting/view command.
function actions.adjust_precision(bufnr, col, delta)
  local st = M.get_state(bufnr)
  local fmt = ensure_format(st, col)
  fmt.precision = math.max(0, (fmt.precision or 2) + delta)
  M.on_state_changed(bufnr)
end

function actions.increase_precision_under_cursor(bufnr)
  actions.adjust_precision(bufnr, M.get_cursor_column(bufnr), 1)
end

function actions.decrease_precision_under_cursor(bufnr)
  actions.adjust_precision(bufnr, M.get_cursor_column(bufnr), -1)
end

--- Free-form format string for a column (e.g. a printf/strftime-style
--- pattern), typed in by hand.
function actions.set_format(bufnr, col, format_str)
  local st = M.get_state(bufnr)
  ensure_format(st, col).format = format_str
  M.on_state_changed(bufnr)
end

function actions.set_format_prompt_under_cursor(bufnr)
  local col = M.get_cursor_column(bufnr)
  local st = M.get_state(bufnr)
  local current = st.column_format[col] and st.column_format[col].format
  vim.ui.input({ prompt = "Format for " .. col .. ": ", default = current }, function(value)
    if value == nil then return end
    actions.set_format(bufnr, col, value)
  end)
end

function actions.adjust_width(bufnr, col, delta)
  local st = M.get_state(bufnr)
  local fmt = ensure_format(st, col)
  fmt.width = math.max(1, (fmt.width or 10) + delta)
  M.on_state_changed(bufnr)
end

function actions.increase_width_under_cursor(bufnr)
  actions.adjust_width(bufnr, M.get_cursor_column(bufnr), 1)
end

function actions.decrease_width_under_cursor(bufnr)
  actions.adjust_width(bufnr, M.get_cursor_column(bufnr), -1)
end

-- ---- paging ------------------------------------------------------------

function actions.next_page(bufnr)
  local st = M.get_state(bufnr)
  st.page = st.page + 1
  M.on_state_changed(bufnr)
end

function actions.prev_page(bufnr)
  local st = M.get_state(bufnr)
  st.page = math.max(0, st.page - 1)
  M.on_state_changed(bufnr)
end

function actions.goto_page(bufnr, page)
  local st = M.get_state(bufnr)
  st.page = math.max(0, page)
  M.on_state_changed(bufnr)
end

function actions.set_page_size(bufnr, size)
  local st = M.get_state(bufnr)
  st.page_size = size
  st.page = 0
  M.on_state_changed(bufnr)
end

function actions.set_page_size_prompt(bufnr)
  local st = M.get_state(bufnr)
  vim.ui.input({ prompt = "Page size: ", default = tostring(st.page_size) }, function(value)
    local n = tonumber(value)
    if not n then return end
    actions.set_page_size(bufnr, math.floor(n))
  end)
end

function actions.first_page(bufnr)
  actions.goto_page(bufnr, 0)
end

function actions.last_page(bufnr)
  local count = M.get_page_count(bufnr)
  actions.goto_page(bufnr, math.max(0, count - 1))
end

-- ---- journal (edits, keyed by column then row index) ---------------------

--- Record/overwrite a pending edit. Does not touch the source file —
--- that's the flush step, built on top of M.journal_entries() below.
function actions.edit_cell(bufnr, col, rowid, value)
  local st = M.get_state(bufnr)
  st.journal[col] = st.journal[col] or {}
  st.journal[col][rowid] = value
  st.dirty = true
  M.on_state_changed(bufnr)
end

function actions.edit_cell_prompt(bufnr, col, rowid)
  local st = M.get_state(bufnr)
  local current = st.journal[col] and st.journal[col][rowid]
  vim.ui.input({ prompt = string.format("%s[%s] = ", col, tostring(rowid)), default = current }, function(value)
    if value == nil then return end
    actions.edit_cell(bufnr, col, rowid, value)
  end)
end

function actions.edit_cell_under_cursor(bufnr)
  local col = M.get_cursor_column(bufnr)
  local rowid = M.get_cursor_rowid(bufnr)
  actions.edit_cell_prompt(bufnr, col, rowid)
end

--- Undo a single pending edit.
function actions.undo_edit(bufnr, col, rowid)
  local st = M.get_state(bufnr)
  if st.journal[col] then
    st.journal[col][rowid] = nil
    if next(st.journal[col]) == nil then
      st.journal[col] = nil
    end
  end
  st.dirty = next(st.journal) ~= nil
  M.on_state_changed(bufnr)
end

function actions.undo_edit_under_cursor(bufnr)
  local col = M.get_cursor_column(bufnr)
  local rowid = M.get_cursor_rowid(bufnr)
  actions.undo_edit(bufnr, col, rowid)
end

--- Drop every pending edit without writing anything.
function actions.discard_journal(bufnr)
  local st = M.get_state(bufnr)
  st.journal = {}
  st.dirty = false
  M.on_state_changed(bufnr)
end

--- Flatten the journal into a flush-friendly list, e.g. for building a
--- chain of `qsv edit <file> <col> <row> <value> | qsv edit - ...`.
--- Returns: { {col=, rowid=, value=}, ... }
function M.journal_entries(bufnr)
  local st = M.get_state(bufnr)
  local entries = {}
  for col, rows in pairs(st.journal) do
    for rowid, value in pairs(rows) do
      table.insert(entries, { col = col, rowid = rowid, value = value })
    end
  end
  return entries
end

function M.journal_count(bufnr)
  return #M.journal_entries(bufnr)
end

--- Call after a successful flush to disk to clear the journal and dirty flag
--- without triggering a full state reset (filters/sort/etc. are untouched).
function actions.mark_flushed(bufnr)
  local st = M.get_state(bufnr)
  st.journal = {}
  st.dirty = false
  M.on_state_changed(bufnr)
end

-- ---- misc ------------------------------------------------------------

function actions.refresh(bufnr)
  M.on_state_changed(bufnr)
end

--- Reset everything: filters, sort, page, visible columns, marks, journal.
function actions.clear_all(bufnr)
  M.reset_state(bufnr)
end

--- Small summary table, handy for a statusline segment.
function M.describe_state(bufnr)
  local st = M.get_state(bufnr)
  local marked_count = 0
  for _ in pairs(st.marked) do marked_count = marked_count + 1 end
  return {
    filters = #st.filters,
    sort    = st.sort and #st.sort or 0,
    page    = st.page,
    hidden  = st.visible and (#M.get_source_columns(bufnr) - #st.visible) or 0,
    marked  = marked_count,
    pending_edits = M.journal_count(bufnr),
    dirty   = st.dirty,
  }
end

-- ==========================================================================
-- Keymaps — configurable table: key combo -> action name (key into M.actions)
-- ==========================================================================

M.keymaps = {
  -- filters
  ["f"]          = "filter_text_prompt",
  ["F"]          = "filter_expr_prompt",
  ["*"]          = "toggle_marked_filter",
  ["<BS>"]       = "pop_filter",
  ["<leader>fc"] = "clear_filters",

  -- sort
  ["s"]          = "sort_under_cursor",
  ["S"]          = "add_sort_key_under_cursor",
  ["<leader>sc"] = "clear_sort",

  -- columns
  ["x"]          = "hide_column_under_cursor",
  ["X"]          = "show_all_columns",
  ["<"]          = "move_column_left_under_cursor",
  [">"]          = "move_column_right_under_cursor",

  -- marks
  ["m"]          = "toggle_mark_under_cursor",
  ["M"]          = "clear_marks",

  -- paging
  ["]"]          = "next_page",
  ["["]          = "prev_page",

  -- editing
  ["e"]          = "edit_cell_under_cursor",
  ["u"]          = "undo_edit_under_cursor",
  ["<leader>ed"] = "discard_journal",

  -- misc
  ["<leader>r"]  = "refresh",
  ["<leader>x"]  = "clear_all",
}

--- Apply a keymap table (M.keymaps by default, or opts.keymaps to override)
--- as buffer-local normal-mode mappings on `bufnr`.
function M.apply_keymaps(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  opts = opts or {}
  local keymaps = opts.keymaps or M.keymaps
  local mode = opts.mode or "n"
  for lhs, action_name in pairs(keymaps) do
    local fn = M.actions[action_name]
    if not fn then
      vim.notify(
        string.format("csv.lua: keymap %q refers to unknown action %q", lhs, action_name),
        vim.log.levels.WARN
      )
    else
      vim.keymap.set(mode, lhs, function() fn(bufnr) end, {
        buffer = bufnr,
        desc = "csv: " .. action_name,
      })
    end
  end
end

-- ==========================================================================
-- Entry point
-- ==========================================================================

--- Initialize state + keymaps for a buffer viewing `source_path`.
--- Call this from your filetype autocmd / user command once the pipeline
--- hooks above are wired up.
function M.attach(bufnr, source_path, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local st = M.get_state(bufnr)
  st.source = source_path
  M.apply_keymaps(bufnr, opts)
  return st
end

return M
