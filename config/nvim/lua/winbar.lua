local M = {}


local winbar_filetype_exclude = {
  ["startify"] = true,
  ["dashboard"] = true,
  ["packer"] = true,
  ["neogitstatus"] = true,
  ["NvimTree"] = true,
  ["Trouble"] = true,
  ["alpha"] = true,
  ["lir"] = true,
  ["Outline"] = true,
  ["spectre_panel"] = true,
  ["toggleterm"] = true,
  ["neo-tree"] = true,
  [""] = true,
}

-- mode_map copied from: 
-- https://github.com/nvim-lualine/lualine.nvim/blob/5113cdb32f9d9588a2b56de6d1df6e33b06a554a/lua/lualine/utils/mode.lua
-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
mode_map = {
  ['n']      = 'NORMAL',
  ['no']     = 'O-PENDING',
  ['nov']    = 'O-PENDING',
  ['noV']    = 'O-PENDING',
  ['no\22'] = 'O-PENDING',
  ['niI']    = 'NORMAL',
  ['niR']    = 'NORMAL',
  ['niV']    = 'NORMAL',
  ['nt']     = 'NORMAL',
  ['v']      = 'VISUAL',
  ['vs']     = 'VISUAL',
  ['V']      = 'V-LINE',
  ['Vs']     = 'V-LINE',
  ['\22']   = 'V-BLOCK',
  ['\22s']  = 'V-BLOCK',
  ['s']      = 'SELECT',
  ['S']      = 'S-LINE',
  ['\19']   = 'S-BLOCK',
  ['i']      = 'INSERT',
  ['ic']     = 'INSERT',
  ['ix']     = 'INSERT',
  ['R']      = 'REPLACE',
  ['Rc']     = 'REPLACE',
  ['Rx']     = 'REPLACE',
  ['Rv']     = 'V-REPLACE',
  ['Rvc']    = 'V-REPLACE',
  ['Rvx']    = 'V-REPLACE',
  ['c']      = 'COMMAND',
  ['cv']     = 'EX',
  ['ce']     = 'EX',
  ['r']      = 'REPLACE',
  ['rm']     = 'MORE',
  ['r?']     = 'CONFIRM',
  ['!']      = 'SHELL',
  ['t']      = 'TERMINAL',
}

local function isempty(s)
  return s == nil or s == ""
end

local should_skip = function()
  if winbar_filetype_exclude[vim.bo.filetype] then
    return true
  end

  local cfg = vim.api.nvim_win_get_config(0)
  if cfg.relative > "" or cfg.external then
    return true
  end
end

local icon_cache = {}

M.get_icon = function()
  if vim.bo.modified then
    return " %#WinBarModified#%*"
  end

  local filename, extension
  if vim.bo.filetype == "terminal" then
    filename = "terminal"
    extension = "terminal"
  else
    filename = vim.fn.expand("%:t")
  end

  local cached = icon_cache[filename]
  if not cached then
    if not extension then
      extension = vim.fn.expand("%:e")
    end
    local file_icon, hl_group = require("nvim-web-devicons").get_icon( filename, extension)
    cached = " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*"
    icon_cache[filename] = cached
  end
  return cached
end

M.get_filename = function()
  local has_icon, icon = pcall(M.get_icon)
  if has_icon then
    return icon .. " %t"
  else
    return " %t"
  end
end

local is_current = function()
  local winid = vim.g.actual_curwin
  if isempty(winid) then
    return false
  else
    return winid == tostring(vim.api.nvim_get_current_win())
  end
end

local sign_cache = {}
local get_sign = function(severity)
  local defined = vim.fn.sign_getdefined("DiagnosticSign" .. severity)
  local text, highlight
  defined = defined and defined[1]
  if defined and defined.text and defined.texthl then
    -- for some reason it always comes padded with a space
    if type(defined.text) == "string" and defined.text:sub(#defined.text) == " " then
      defined.text = defined.text:sub(1, -2)
    end
    text = " " .. defined.text
    highlight = defined.texthl
  else
    text = " " .. severity:sub(1, 1)
    highlight = "Diagnostic" .. severity
  end
  return "%#" .. highlight .. "#" .. text .. "%* "
end

M.get_diag = function ()
  local d = vim.diagnostic.get(0)
  if #d == 0 then
    return ""
  end

  local min_severity = 100
  for _, diag in ipairs(d) do
    if diag.severity < min_severity then
      min_severity = diag.severity
    end
  end
  local severity = ""
  if min_severity == vim.diagnostic.severity.ERROR then
    severity = "Error"
  elseif min_severity == vim.diagnostic.severity.WARN then
    severity = "Warn"
  elseif min_severity == vim.diagnostic.severity.INFO then
    severity = "Info"
  elseif min_severity == vim.diagnostic.severity.HINT then
    severity = "Hint"
  else
    return ""
  end

  local cached = sign_cache[severity]
  if not cached then
    cached = get_sign(severity)
    sign_cache[severity] = cached
  end
  return cached
end

M.get_location = function()
  local success, result = pcall(function ()
    if not is_current() then
      return ""
    end
    local provider = require("nvim-navic")
    if not provider.is_available() then
      return ""
    end

    local location = provider.get_location({})
    if not isempty(location) and location ~= "error" then
      return "%#WinBarLocation#  " .. location .. "%*"
    else
      return ""
    end
  end)

  if not success then
    return ""
  end
  return result
end

M.get_mode = function ()
  if not is_current() then
    return ""
  end
  local mode_code = vim.api.nvim_get_mode().mode
  local mode = mode_map[mode_code] or string.upper(mode_code)
  return "%#Mode" .. mode:sub(1, 1) .. "# " .. mode .. " %*"

end

M.get_winbar = function()
  if vim.bo.buftype == "terminal" then
    return "%{%v:lua.winbar.get_mode()%}%{%v:lua.winbar.get_icon()%} TERMINAL #%n %#WinBarLocation# %{b:term_title}%*"
  else
    if should_skip() then
      return ""
    else
      local buftype = vim.bo.buftype
      -- real files do not have buftypes
      if isempty(buftype) then
        return "%{%v:lua.winbar.get_mode()%}%{%v:lua.winbar.get_filename()%}%<%{%v:lua.winbar.get_location()%}%=%{%v:lua.winbar.get_diag()%}"
      else
        return "%h %f"
      end
    end
  end
end

vim.cmd [[
  highlight WinBar           guifg=#BBBBBB gui=bold
  highlight WinBarNC         guifg=#888888 gui=bold
  highlight WinBarLocation   guifg=#888888 gui=bold
  highlight WinBarModified   guifg=#d7d787


  highlight ModeC guibg=#dddddd guifg=#101010 gui=bold " COMMAND 
  highlight ModeI guibg=#ffff5f guifg=#353535 gui=bold " INSERT  
  highlight ModeT guibg=#95e454 guifg=#353535 gui=bold " TERMINAL
  highlight ModeN guibg=#8ac6f2 guifg=#353535 gui=bold " NORMAL  
  highlight ModeV guibg=#c586c0 guifg=#353535 gui=bold " VISUAL  
  highlight ModeR guibg=#f44747 guifg=#353535 gui=bold " REPLACE 
]]

_G.winbar = M
vim.o.winbar="%{%v:lua.winbar.get_winbar()%}"

return M
