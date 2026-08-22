--[[
Where the cursor sits in the painted table.

Every question here is answered from the line the cursor is on, never from the
header, because `xan view` pads cells to display width and a line holding a
multi-byte character puts its separators at different byte offsets.

Cell 1 is the row id, so the column under the cursor is cell 2 onwards.
]]

local layout = require("csv.layout")
local selection = require("csv.selection")

local M = {}

local flash_namespace = vim.api.nvim_create_namespace("csv-flash")
local FLASH_MILLISECONDS = 250

--- Put the cursor in `cell` without changing which line it is on.
---@param buffer csv.Buffer
---@param window integer
---@param cell integer
function M.focus_cell(buffer, window, cell)
  if not buffer.layout then
    return
  end

  local position = vim.api.nvim_win_get_cursor(window)
  local line = buffer.layout.lines[position[1]]
  local from = line and layout.cell_bounds(line, cell)
  if from then
    vim.api.nvim_win_set_cursor(window, { position[1], from + 1 })
  end
end

--- Put the cursor on the first data row, past the row id, so it starts on a
--- cell the column actions can act on.
---@param buffer csv.Buffer
function M.focus_first_row(buffer)
  local painted = buffer.layout
  if not painted or painted.first_row > painted.last_row then
    return
  end

  local window = vim.fn.bufwinid(buffer.bufnr)
  if window == -1 then
    return
  end

  vim.api.nvim_win_set_cursor(window, { painted.first_row, 0 })
  M.focus_cell(buffer, window, 2)
end

--- Highlight one cell of every row briefly. Repainting clears extmarks, so this
--- only holds while the text it describes is the text on screen.
---@param buffer csv.Buffer
---@param cell integer
function M.flash_cell(buffer, cell)
  if not buffer.layout then
    return
  end

  vim.api.nvim_buf_clear_namespace(buffer.bufnr, flash_namespace, 0, -1)
  for index = buffer.layout.header, buffer.layout.last_row do
    local from, to = layout.cell_bounds(buffer.layout.lines[index], cell)
    if from then
      vim.api.nvim_buf_set_extmark(buffer.bufnr, flash_namespace, index - 1, from, {
        end_col = to,
        hl_group = "CsvFlash",
      })
    end
  end

  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(buffer.bufnr) then
      vim.api.nvim_buf_clear_namespace(buffer.bufnr, flash_namespace, 0, -1)
    end
  end, FLASH_MILLISECONDS)
end

--- The column under the cursor, or nil when the cursor is on the row id, a
--- border, or past the last column.
---@param buffer csv.Buffer
---@param window integer
---@return csv.Column|nil
function M.column_at(buffer, window)
  if not buffer.layout then
    return nil
  end

  local position = vim.api.nvim_win_get_cursor(window)
  local line = buffer.layout.lines[position[1]]
  if not line then
    return nil
  end

  local cell = layout.cell_at(line, position[2])
  if not cell or cell < 2 then
    return nil
  end
  return selection.selected(buffer.state)[cell - 1]
end

--- Move the cursor one column left or right.
---@param buffer csv.Buffer
---@param window integer
---@param delta integer
function M.jump_column(buffer, window, delta)
  if not buffer.layout then
    return
  end

  local position = vim.api.nvim_win_get_cursor(window)
  local line = buffer.layout.lines[position[1]]
  if not line then
    return
  end
  M.focus_cell(buffer, window, (layout.cell_at(line, position[2]) or 1) + delta)
end

--- The source row id under the cursor, or nil when the cursor is not on a row.
---@param buffer csv.Buffer
---@param window integer
---@return integer|nil
function M.rowid_at(buffer, window)
  if not buffer.layout then
    return nil
  end

  local position = vim.api.nvim_win_get_cursor(window)
  return buffer.layout.rowids[position[1]]
end

return M
