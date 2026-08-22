--[[
The dialogs that ask the user to choose something.

The filter dialog offers the comparisons that suit the column's detected kind,
so a numeric column never offers `contains` and a text column never offers `>`,
and it offers the column's own values as a checklist. The value list is drawn
through the filters already applied, so every value it shows is one that would
leave rows on screen.

The sheet dialog lists the sheets of a workbook.
]]

local buffer = require("csv.buffer")
local columns = require("csv.columns")
local query = require("csv.query")
local state = require("csv.state")
local window = require("csv.window")

local M = {}

---@class csv.Choice
---@field key string
---@field label string
---@field type "numeric"|"string"
---@field operator string

---@type csv.Choice[]
local NUMERIC_CHOICES = {
  { key = ">", label = "greater than", type = "numeric", operator = ">" },
  { key = ")", label = "greater than or equal to", type = "numeric", operator = ">=" },
  { key = "<", label = "less than", type = "numeric", operator = "<" },
  { key = "(", label = "less than or equal to", type = "numeric", operator = "<=" },
  { key = "=", label = "equal to", type = "numeric", operator = "==" },
  { key = "!", label = "not equal to", type = "numeric", operator = "!=" },
}

---@type csv.Choice[]
local TEXT_CHOICES = {
  { key = "=", label = "equal to", type = "string", operator = "eq" },
  { key = "!", label = "not equal to", type = "string", operator = "ne" },
  { key = "~", label = "containing", type = "string", operator = "contains" },
  { key = "^", label = "starting with", type = "string", operator = "startswith" },
  { key = "$", label = "ending with", type = "string", operator = "endswith" },
  { key = "/", label = "matching a regular expression", type = "string", operator = "regex" },
}

---@param message string
local function report(message)
  vim.notify("csv: " .. message, vim.log.levels.ERROR)
end

--- Draw the checklist for the value picker.
---@param values csv.Frequency[]
---@param chosen table<integer, boolean>
---@return string[]
local function checklist(values, chosen)
  local lines = {}
  for index, entry in ipairs(values) do
    lines[index] = string.format(
      "  [%s] %-40s %s",
      chosen[index] and "x" or " ",
      entry.value,
      entry.count
    )
  end
  return lines
end

--- Choose values from the column's own contents.
--- The float is an ordinary buffer, so `/` searches the list the way it
--- searches anything else.
---@param buf csv.Buffer
---@param column csv.Column
---@param values csv.Frequency[]
local function pick_values(buf, column, values)
  if #values == 0 then
    return report("no values in " .. columns.display(column))
  end

  local chosen = {}
  local bufnr, winid = window.open(checklist(values, chosen), {
    title = columns.display(column) .. "  (space toggles, enter applies)",
    modifiable = true,
  })

  local function redraw()
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, checklist(values, chosen))
    vim.bo[bufnr].modifiable = false
  end
  redraw()

  vim.keymap.set("n", "<Space>", function()
    local line = vim.api.nvim_win_get_cursor(winid)[1]
    chosen[line] = not chosen[line] or nil
    redraw()
    vim.api.nvim_win_set_cursor(winid, { line, 0 })
  end, { buffer = bufnr, nowait = true })

  vim.keymap.set("n", "<CR>", function()
    local picked = {}
    for index in pairs(chosen) do
      table.insert(picked, values[index].value)
    end
    window.close(winid)

    if #picked == 0 then
      return
    end
    table.sort(picked)
    state.add_filter(buf.state, { type = "in", column = column, values = picked })
    buffer.render(buf)
  end, { buffer = bufnr, nowait = true })
end

--- Ask for the value a comparison compares against, then apply it.
---@param buf csv.Buffer
---@param column csv.Column
---@param choice csv.Choice
local function ask_for_value(buf, column, choice)
  vim.ui.input({ prompt = columns.display(column) .. " " .. choice.label .. ": " }, function(answer)
    if answer == nil or answer == "" then
      return
    end

    if choice.type == "numeric" then
      local number = tonumber(answer)
      if not number then
        return report(answer .. " is not a number")
      end
      state.add_filter(buf.state, {
        type = "numeric",
        column = column,
        operator = choice.operator,
        value = number,
      })
    else
      state.add_filter(buf.state, {
        type = "string",
        column = column,
        operator = choice.operator,
        value = answer,
      })
    end
    buffer.render(buf)
  end)
end

--- Choose which sheet of a workbook to read.
---@param buf csv.Buffer
function M.sheets(buf)
  local sheets = buf.state.sheets
  if #sheets == 0 then
    return report(vim.fn.fnamemodify(buf.state.source, ":t") .. " has no sheets")
  end

  local lines = {}
  for index, name in ipairs(sheets) do
    lines[index] = string.format(
      "  %s %d  %s",
      index - 1 == buf.state.sheet and "▸" or " ",
      index,
      name
    )
  end

  local bufnr, winid = window.open(lines, { title = "Sheets" })
  vim.api.nvim_win_set_cursor(winid, { buf.state.sheet + 1, 0 })

  vim.keymap.set("n", "<CR>", function()
    local chosen = vim.api.nvim_win_get_cursor(winid)[1] - 1
    window.close(winid)
    if chosen ~= buf.state.sheet then
      buffer.open_sheet(buf, chosen)
    end
  end, { buffer = bufnr, nowait = true })
end

--- Open the dialog for `column`.
---@param buf csv.Buffer
---@param column csv.Column
function M.open(buf, column)
  local choices = state.is_numeric(buf.state, column) and NUMERIC_CHOICES or TEXT_CHOICES

  local lines = {}
  for index, choice in ipairs(choices) do
    lines[index] = string.format("  %s   %s", choice.key, choice.label)
  end
  table.insert(lines, "")
  table.insert(lines, "  v   choose from the values in this column")
  table.insert(lines, "  e   a moonblade expression")

  local bufnr, winid = window.open(lines, { title = "Filter " .. columns.display(column) })

  for _, choice in ipairs(choices) do
    vim.keymap.set("n", choice.key, function()
      window.close(winid)
      ask_for_value(buf, column, choice)
    end, { buffer = bufnr, nowait = true })
  end

  vim.keymap.set("n", "v", function()
    window.close(winid)
    query.frequency(buf.state, column, report, function(values)
      pick_values(buf, column, values)
    end)
  end, { buffer = bufnr, nowait = true })

  vim.keymap.set("n", "e", function()
    window.close(winid)
    vim.ui.input({ prompt = "moonblade expression: " }, function(expression)
      if expression == nil or expression == "" then
        return
      end
      state.add_filter(buf.state, { type = "expr", expression = expression })
      buffer.render(buf)
    end)
  end, { buffer = bufnr, nowait = true })
end

return M
