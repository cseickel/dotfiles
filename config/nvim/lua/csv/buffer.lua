--[[
The buffer a CSV is shown in.

Owns one record per buffer, holding the state the user is building and the
layout of what is currently painted. Rendering runs the pipeline and replaces
every line, so the layout is rebuilt on each paint and nothing derived from it
outlives the text it describes.

The buffer stays nomodifiable. Its text is xan's output, not a document.
]]

local commands = require("csv.commands")
local cursor = require("csv.cursor")
local layout = require("csv.layout")
local query = require("csv.query")
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

local mark_namespace = vim.api.nvim_create_namespace("csv-marks")

--- Paint the marks over the text just written. Replacing every line drops all
--- extmarks, so marks have to be reapplied with each paint or they vanish on
--- the first page turn.
---@param buffer csv.Buffer
local function apply_marks(buffer)
  local painted = buffer.layout
  vim.api.nvim_buf_clear_namespace(buffer.bufnr, mark_namespace, 0, -1)

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
  query.run(commands.render(buffer.state), report, function(stdout)
    if not vim.api.nvim_buf_is_valid(buffer.bufnr) then
      return
    end

    local parsed, err = layout.parse(vim.split(stdout, "\n", { plain = true }))
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
end

--- Read another sheet of the same workbook. The filters, sort, marks, column
--- selection and formats all name columns of the sheet being left, so the view
--- starts clean rather than carrying them onto columns that may not exist.
---@param buffer csv.Buffer
---@param sheet integer 0-based.
function M.open_sheet(buffer, sheet)
  source.inspect(buffer.state.source, sheet, function(inspected)
    if not vim.api.nvim_buf_is_valid(buffer.bufnr) then
      return
    end

    buffer.state = state.new(inspected)
    M.render(buffer, function()
      cursor.focus_first_row(buffer)
    end)
  end, report)
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
  -- A rendered row runs past the 3000 column default on a wide file, and syntax
  -- highlighting stops at that column, so the borders would fade out to the right.
  vim.bo[bufnr].synmaxcol = 0
  vim.bo[bufnr].filetype = "csv-table"

  -- A table is read by scrolling sideways, so wrapping would break every row
  -- into a variable number of screen lines and unalign the columns. Line
  -- numbers go too, since the table carries the row's own id in column one.
  local function dress_windows()
    for _, window in ipairs(vim.fn.win_findbuf(bufnr)) do
      vim.wo[window].wrap = false
      vim.wo[window].number = false
      vim.wo[window].relativenumber = false
    end
  end
  dress_windows()
  vim.api.nvim_create_autocmd("BufWinEnter", { buffer = bufnr, callback = dress_windows })

  source.inspect(path, nil, function(inspected)
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

    M.render(buffer, function()
      cursor.focus_first_row(buffer)
    end)
    if on_ready then
      on_ready(buffer)
    end
  end, report)
end

return M
