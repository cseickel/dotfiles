--[[
The buffer a CSV is shown in.

Owns one record per buffer, holding the state the user is building and the
layout of what is currently painted. Rendering runs the pipeline and replaces
every line, so the layout is rebuilt on each paint and nothing derived from it
outlives the text it describes.

The buffer stays nomodifiable. Its text is xan's output, not a document.
]]

local layout = require("csv.layout")
local pipeline = require("csv.pipeline")
local selection = require("csv.selection")
local source = require("csv.source")
local state = require("csv.state")

local M = {}

---@class csv.Buffer
---@field bufnr integer
---@field state csv.State
---@field layout csv.Layout|nil Absent until the first paint succeeds.

---@type table<integer, csv.Buffer>
local buffers = {}

local flash_namespace = vim.api.nvim_create_namespace("csv-flash")
local mark_namespace = vim.api.nvim_create_namespace("csv-marks")
local FLASH_MILLISECONDS = 250

--- Paint the marks over the text just written. Replacing every line drops all
--- extmarks, so marks have to be reapplied with each paint or they vanish on
--- the first page turn.
---@param buffer csv.Buffer
local function apply_marks(buffer)
  local painted = buffer.layout
  vim.api.nvim_buf_clear_namespace(buffer.bufnr, mark_namespace, 0, -1)

  -- Add heder highlight
  if buffer.state.header then
    vim.api.nvim_buf_set_extmark(buffer.bufnr, mark_namespace, 0, 0, {
      line_hl_group = "CsvHeader",
      end_row = 1
    })
  end

  -- Set hl for line drawing borders
  vim.api.nvim_buf_set_extmark(buffer.bufnr, mark_namespace, 1, 0, {
    line_hl_group = "CsvBorder",
  })
  vim.api.nvim_buf_set_extmark(buffer.bufnr, mark_namespace, 0, 0, {
    conceal = "│",
    end_row = painted.last_row
  })

  for line = painted.first_row, painted.last_row do
    local rowid = painted.rowids[line]
    if rowid and buffer.state.marked[rowid] then
      vim.api.nvim_buf_set_extmark(buffer.bufnr, mark_namespace, line - 1, 0, {
        line_hl_group = "CsvMarkedRow",
      })
    end
  end

  for position, column in ipairs(selection.selected(buffer.state)) do
    if buffer.state.marked_columns[column.index] then
      local from, to = layout.cell_bounds(painted.lines[painted.header], position + 1)
      if from then
        vim.api.nvim_buf_set_extmark(buffer.bufnr, mark_namespace, painted.header - 1, from, {
          end_col = to,
          hl_group = "CsvMarkedColumn",
        })
      end
    end
  end
end

---@param bufnr integer
---@return csv.Buffer|nil
function M.get(bufnr)
  return buffers[bufnr]
end

---@param message string
local function report(message)
  vim.notify("csv: " .. message, vim.log.levels.ERROR)
end

---@param bufnr integer
---@param lines string[]
local function replace_lines(bufnr, lines)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

--- Run the pipeline for `buffer` and paint what it returns.
---@param buffer csv.Buffer
---@param on_painted fun()|nil Runs once the new text is in the buffer.
function M.render(buffer, on_painted)
  vim.system(
    pipeline.command(buffer.state),
    { text = true },
    vim.schedule_wrap(function(result)
      if not vim.api.nvim_buf_is_valid(buffer.bufnr) then
        return
      end
      if result.code ~= 0 then
        return report(vim.trim(result.stderr))
      end

      local lines = vim.split(result.stdout, "\n", { plain = true })
      local parsed, err = layout.parse(lines)
      if not parsed then
        return report(err)
      end

      buffer.layout = parsed
      replace_lines(buffer.bufnr, parsed.lines)
      apply_marks(buffer)
      -- `status.get_winbar` pins this line while the buffer is scrolled past it.
      vim.b[buffer.bufnr].table_header = parsed.header

      if on_painted then
        on_painted()
      end
    end)
  )
end

--- Put the cursor in `cell` without changing which line it is on.
---@param buffer csv.Buffer
---@param window integer
---@param cell integer
function M.focus_cell(buffer, window, cell)
  if not buffer.layout then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(window)
  local line = buffer.layout.lines[cursor[1]]
  local from = line and layout.cell_bounds(line, cell)
  if from then
    vim.api.nvim_win_set_cursor(window, { cursor[1], from + 1 })
  end
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

--- The rows of the result on display, counting from one.
---@param buffer csv.Buffer
---@return integer first
---@return integer last
function M.row_range(buffer)
  local first = buffer.state.page * buffer.state.limit + 1
  if not buffer.layout then
    return first, first - 1
  end
  return first, first + layout.row_count(buffer.layout) - 1
end

--- The column under the cursor, or nil when the cursor is on the row id, a
--- border, or past the last column.
---@param buffer csv.Buffer
---@param window integer
---@return csv.Column|nil
function M.column_at_cursor(buffer, window)
  if not buffer.layout then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(window)
  local line = buffer.layout.lines[cursor[1]]
  if not line then
    return nil
  end

  local cell = layout.cell_at(line, cursor[2])
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

  local cursor = vim.api.nvim_win_get_cursor(window)
  local line = buffer.layout.lines[cursor[1]]
  if not line then
    return
  end
  M.focus_cell(buffer, window, (layout.cell_at(line, cursor[2]) or 1) + delta)
end

--- Whether the painted page is the last one, which is true when it came back
--- short. Nothing counts the rows a filter matches, so a short page is the only
--- signal that paging further would show an empty table.
---@param buffer csv.Buffer
---@return boolean
function M.at_last_page(buffer)
  if not buffer.layout then
    return false
  end
  return layout.row_count(buffer.layout) < buffer.state.limit
end

--- The source row id under the cursor, or nil when the cursor is not on a row.
---@param buffer csv.Buffer
---@param window integer
---@return integer|nil
function M.rowid_at_cursor(buffer, window)
  if not buffer.layout then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(window)
  return buffer.layout.rowids[cursor[1]]
end

--- Take over `bufnr`, which nvim has named after a CSV file but has not read.
--- The table replaces the file's text, so the buffer is `nowrite`: writing the
--- rendered table back over the source would destroy it.
---@param bufnr integer
---@param on_ready fun(buffer: csv.Buffer)|nil
function M.attach(bufnr, on_ready)
  -- `:edit` fires the read command again on a buffer already showing a table,
  -- and means refresh rather than attach.
  local attached = buffers[bufnr]
  if attached then
    return M.render(attached)
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return report("buffer has no file name")
  end

  vim.bo[bufnr].buftype = "nowrite"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].filetype = "csvtable"

  -- A table is read by scrolling sideways, so wrapping it would break every row
  -- into a variable number of screen lines and unalign the columns.
  local function unwrap()
    for _, window in ipairs(vim.fn.win_findbuf(bufnr)) do
      vim.wo[window].wrap = false
    end
  end
  unwrap()
  vim.api.nvim_create_autocmd("BufWinEnter", { buffer = bufnr, callback = unwrap })

  source.inspect(path, function(inspected)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    local buffer = { bufnr = bufnr, state = state.new(inspected), layout = nil }
    buffers[bufnr] = buffer

    vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
      buffer = bufnr,
      callback = function()
        buffers[bufnr] = nil
      end,
    })

    M.render(buffer)
    if on_ready then
      on_ready(buffer)
    end
  end, report)
end

return M
