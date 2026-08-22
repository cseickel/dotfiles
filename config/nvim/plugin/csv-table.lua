-- @class WhereConditionIn
-- @field column string
-- @field type "in"
-- @field values table

-- @alias numericOperator "<" | "<=" | ">" | ">="

-- @class WhereConditionNumeric
-- @field column string
-- @field type "numeric"
-- @field operator numericOperator
-- @field value number
--
-- @alias stringOperator "contains" | "starts_with" | "ends_with" | "equals" | "not_equals" | "regex"
--
-- @class WhereConditionString
-- @field column string
-- @field type "string"
-- @field operator stringOperator
-- @field value string

-- @class WhereConditionBoolean
-- @field column string
-- @field type "boolean"
-- @field value boolean

-- @alias WhereCondition WhereConditionIn | WhereConditionNumeric | WhereConditionString | WhereConditionBoolean

-- @class Order
-- @field column string
-- @field type "asc" | "desc"

-- @class BufferState
-- @field bufnr number
-- @field path string
-- @field where WhereCondition[]
-- @field select string[]
-- @field order Order[]
-- @field limit number
-- @field page number
-- @field marked_rows number[]
-- @field pending_edits PendingEdit[]
--

local M = {}

-- @type table<number, BufferState>
local buffer_state = {}

-- @param bufnr number
-- @param path string
-- @return BufferState
local function init_file(bufnr, path)
  local state = buffer_state[bufnr]
  if state and state.path == path then return state end
  state = {
    bufnr = bufnr,
    path = path,
    where = {},
    select = {},
    order = {},
    limit = 1000,
    page = 0,
    marked_rows = {},
    marked_columns = {},
    pending_edits = {},
  }
  buffer_state[bufnr] = state
  return state
end

M.activate = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if buffer_state[bufnr] then return end
  -- build the view and swap the buffer with our formatted one
  bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "csv")
  vim.api.nvim_buf_set_name(bufnr, "[csv-table] " .. path)
  -- set up the keymaps
  for lhs, rhs in pairs(M.keymaps) do
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr })
  end

  local state = init_file(bufnr, path)
  state.winid = vim.api.nvim_get_current_win()
  M.render(bufnr)
end

local build_command = function(state)
  -- build `xan` moonblade script
  local lines = {}
  local head = 0
  for i, line in ipairs(state.where) do
    head = head + 1
    if line.type == "in" then
      lines[head] = string.format("%s in (%s)", line.column, vim.inspect(line.values))
    elseif line.type == "numeric" then
      lines[head] = string.format("%s %s %s", line.column, line.operator, line.value)
    elseif line.type == "string" then
      lines[head] = string.format("%s %s %s", line.column, line.operator, line.value)
    elseif line.type == "boolean" then
      lines[head] = string.format("%s %s", line.column, line.value)
    else
      -- back out the optomistic increment
      head = head - 1
    end
  end
  for i, line in ipairs(state.order) do
    if line.type == "asc" then
      lines[head] = string.format("sort -s %s", line.column)
    elseif line.type == "desc" then
      lines[head] = string.format("sort -s %s -R", line.column)
    end
    head = head + 1
  end
  if state.limit then
    if state.page then
      local offset = (state.page - 1) * state.limit
      lines[head] = string.format("slice %d %d", offset, offset + state.limit)
    else
      lines[head] = string.format("slice 0 %d", state.limit)
    end
    head = head + 1
  end
  if state.select then
    lines[head] = string.format("select %s", vim.inspect(state.select))
    head = head + 1
  end
  lines[head] = "table"
  return table.concat(lines, " | ")
end


M.render = function(bufnr)
  local state = buffer_state[bufnr]
  if not state then return end
  local command = build_command(state)
  -- execute the command, pipe stdout to buffer
  local handle = io.popen(command)
  local lines = {}
  for line in handle:lines() do
    table.insert(lines, line)
  end
  handle:close()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

return M
