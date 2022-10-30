local entry_display = require('telescope.pickers.entry_display')
local utils = require("telescope.utils")
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
  local skip_display = function()
    return nil
  end

  return function(entry)
    local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)
    local symbol_msg = entry.text:gsub(".* | ", "")
    local symbol_type, symbol_name = symbol_msg:match("%[(.+)%]%s+(.*)")

    -- Typescript/JavaScript can get messy, in that case we want any func/const/variables
    -- that are at the top level, because const can can be anything and are probably important.
    local skip = false
    if string.match(vim.bo.filetype, "script") then
      local rootOnlyKinds = {
        ["Function"] = true,
        ["Variable"] = true,
        ["Constant"] = true,
      }
      if rootOnlyKinds[symbol_type] then
        local indent = vim.api.nvim_buf_get_lines(entry.bufnr, entry.lnum - 1, entry.lnum, false)[1]:match("^%s*")
        if string.len(indent) == 0 then
          if symbol_type == "Variable" then
            -- we don't want to capture variables within function signatures
            -- more than 8 chars in is probably within a function signature
            skip = entry.col > 8
          end
        else
          skip = true
        end
      end
    end

    local ordinal = ""
    if not opts.ignore_filename and filename then
      ordinal = filename .. " "
    end
    ordinal = ordinal ..  symbol_name .. " " .. (symbol_type or "unknown")
    return {
      valid = not skip,

      value = entry,
      ordinal = ordinal,
      display = skip and skip_display or make_display,

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

local left_pad = function (str, length)
    return string.rep(' ', length - #str) .. str
end

function make_entry.gen_from_quickfix(opts)
  opts = opts or { width = 80 }
  local opt_width = opts.width
  if type(opts.width) == "function" then
    opt_width = opts.width()
  end
  local file_width = math.max(math.floor(opt_width / 2) - 6, math.min(opt_width - 5, 40))

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = file_width },
      { width = 4 },
      { remaing = true },
    },
  }

  local make_display = function(entry)
    local filename = utils.transform_path(opts, entry.filename)
    local fl = string.len(filename)
    if (fl > file_width) then
        filename = "..." ..filename:sub(fl - file_width + 5)
    end
    local line_info = { entry.lnum, "TelescopeResultsLineNr" }

    return displayer {
        { filename, 'TabLineSel' },
        line_info,
        entry.text:gsub("^%s+", ""),
    }
  end

  return function(entry)
    local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)

    return {
      valid = true,

      value = entry,
      ordinal = (not opts.ignore_filename and filename or "") .. " " .. entry.text,
      display = make_display,

      bufnr = entry.bufnr,
      filename = filename,
      lnum = entry.lnum,
      col = entry.col,
      text = entry.text,
      start = entry.start,
      finish = entry.finish,
    }
  end
end

return make_entry
