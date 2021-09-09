local entry_display = require('telescope.pickers.entry_display')
local vim=vim

local lsp_type_highlight = {
  ["Class"]    = "TSType",
  ["Interface"] = "TSType",
  ["Constant"] = "TelescopeResultsConstant",
  ["Constructor"] = "TSMethod",
  ["Field"]    = "TelescopeResultsField",
  ["Function"] = "TSMethod",
  ["Method"]   = "TSMethod",
  ["Property"] = "TelescopeResultsOperator",
  ["Struct"]   = "TelescopeResultsStruct",
  ["Variable"] = "TelescopeResultsVariable",
}

local symbol_map = {
    Text = '',
    Method = '',
    Function = '',
    Constructor = '',
    Variable = '',
    Class = '',
    Interface = '',
    Module = '',
    Property = '',
    Unit = '',
    Value = '',
    Enum = '了',
    Keyword = '',
    Snippet = '﬌',
    Color = '',
    File = '',
    Folder = '',
    EnumMember = '',
    Constant = '',
    Struct = '',
    Operator = ''
}

local make_entry = {}

function make_entry.gen_from_lsp_symbols(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

  local display_items = {
    { width = 4 }, --line nr
    { width = 1 }, --symbol icon
    { width = opts.symbol_width or 42 },  --symbol
    { width = opts.symbol_type_width or 12 }, -- symbol type
  }

  local displayer = entry_display.create {
    separator = " ",
    hl_chars = { ['['] = 'TelescopeBorder', [']'] = 'TelescopeBorder' },
    items = display_items
  }

  local make_display = function(entry)
    local type_highlight = opts.symbol_highlights or lsp_type_highlight
    local display_columns = {
      {entry.lnum, "LineNr", "LineNr"},
      {symbol_map[entry.symbol_type], type_highlight[entry.symbol_type], type_highlight[entry.symbol_type]},
      {entry.symbol_name, type_highlight[entry.symbol_type], type_highlight[entry.symbol_type]},
      entry.symbol_type
    }

    return displayer(display_columns)
  end

  return function(entry)
    local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)
    local symbol_msg = entry.text:gsub(".* | ", "")
    local symbol_type, symbol_name = symbol_msg:match("%[(.+)%]%s+(.*)")

    local ordinal = ""
    if not opts.ignore_filename and filename then
      ordinal = filename .. " "
    end
    ordinal = ordinal ..  symbol_name .. " " .. (symbol_type or "unknown")
    return {
      valid = true,

      value = entry,
      ordinal = ordinal,
      display = make_display,

      filename = filename,
      lnum = entry.lnum,
      col = entry.col,
      symbol_name = symbol_name,
      symbol_type = symbol_type,
      start = entry.start,
      finish = entry.finish,
    }
  end
end

return make_entry
