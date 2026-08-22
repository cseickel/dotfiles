--[[
Entry point.

Opening a `.csv` is intercepted before nvim reads it, so the file's text never
enters a buffer and its size stops mattering. What the buffer shows instead is
`xan view` output, repainted from view state on every change.

`setup` takes `keymaps` to replace the default bindings and `patterns` to
replace the file patterns that trigger interception.
]]

local actions = require("csv.actions")
local buffer = require("csv.buffer")
local columns = require("csv.columns")
local keymaps = require("csv.keymaps")

local M = {}

M.patterns = { "*.csv", "*.tsv" }

---@param buf csv.Buffer
local function apply_keymaps(buf)
  for key, name in pairs(keymaps.map) do
    local described = actions.actions[name]
    if not described then
      error(string.format("csv: key %q names unknown action %q", key, name))
    end
    vim.keymap.set("n", key, function()
      described.run(buf)
    end, { buffer = buf.bufnr, desc = "csv: " .. described.description })
  end
end

local function define_highlights()
  local defaults = {
    CsvMarkedRow = "DiffAdd",
    CsvMarkedColumn = "DiffText",
    CsvFlash = "Visual",
  }
  for name, link in pairs(defaults) do
    vim.api.nvim_set_hl(0, name, { link = link, default = true })
  end
end

--- What the sort reads as in a statusline.
---@param buf csv.Buffer
---@return string|nil
local function sort_summary(buf)
  if #buf.state.order == 0 then
    return nil
  end

  local parts = {}
  for index, key in ipairs(buf.state.order) do
    parts[index] = columns.display(key.column) .. (key.direction == "asc" and "▲" or "▼")
  end
  return "sort " .. table.concat(parts, " ")
end

--- What is held for pasting, as a statusline fragment.
---@param buf csv.Buffer
---@return string|nil
local function clipboard_summary(buf)
  if #buf.state.clipboard == 0 then
    return nil
  end

  local names = {}
  for index, column in ipairs(buf.state.clipboard) do
    names[index] = columns.display(column)
  end
  return "cut " .. table.concat(names, ",")
end

--- How the page and everything applied to it read in a statusline. Empty for
--- any buffer that is not a table.
---@param bufnr integer
---@return string
function M.status(bufnr)
  local buf = buffer.get(bufnr)
  if not buf or not buf.layout then
    return ""
  end

  local parts = {}
  local first, last = buffer.row_range(buf)
  if last < first then
    table.insert(parts, "no rows")
  elseif buffer.at_last_page(buf) then
    table.insert(parts, string.format("rows %d-%d (end)", first, last))
  else
    table.insert(parts, string.format("rows %d-%d", first, last))
  end

  if #buf.state.where > 0 then
    table.insert(parts, #buf.state.where == 1 and "1 filter" or (#buf.state.where .. " filters"))
  end

  local marked = vim.tbl_count(buf.state.marked)
  if marked > 0 then
    table.insert(parts, marked .. " marked")
  end

  table.insert(parts, sort_summary(buf))
  table.insert(parts, clipboard_summary(buf))
  return table.concat(parts, " · ")
end

---@param opts { keymaps: table<string, string>|nil, patterns: string[]|nil }|nil
function M.setup(opts)
  opts = opts or {}
  if opts.keymaps then
    keymaps.map = opts.keymaps
  end
  if opts.patterns then
    M.patterns = opts.patterns
  end

  define_highlights()

  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = M.patterns,
    callback = function(event)
      buffer.attach(event.buf, apply_keymaps)
    end,
  })

  vim.api.nvim_create_user_command("CsvTable", function(command)
    local path = command.args ~= "" and command.args or vim.api.nvim_buf_get_name(0)
    if path == "" then
      return vim.notify("csv: no file to open", vim.log.levels.ERROR)
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
  end, { nargs = "?", complete = "file", desc = "Open a CSV as a table" })
end

return M
