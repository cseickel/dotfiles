local M = {}


local winbar_filetype_exclude = {
  "help",
  "startify",
  "dashboard",
  "packer",
  "neogitstatus",
  "NvimTree",
  "Trouble",
  "alpha",
  "lir",
  "Outline",
  "spectre_panel",
  "toggleterm",
  "neo-tree",
  "neo-tree-popup",
  "",
}

local function isempty(s)
  return s == nil or s == ""
end

local should_skip = function(true_for_terminals)
  if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
    return true
  end

  local buftype = vim.bo.buftype
  if true_for_terminals and buftype == "terminal" then
    return false
  end
  -- all other buftypes are not real files
  return not isempty(buftype)
end

local function get_icon()
  if vim.bo.modified == 1 then
    return "", "WinBarModified"
  end

  local filename, extension
  if vim.bo.filetype == "terminal" then
    filename = "terminal"
    extension = "terminal"
  else
    filename = vim.fn.expand("%:t")
    extension = vim.fn.expand("%:e")
  end
  return require("nvim-web-devicons").get_icon( filename, extension)
end

local get_filename = function(location_highlight)
  local filename
  if vim.bo.buftype == "terminal" then
    filename = " #TERMINAL #%n %#WinBarLocation# %{b:term_title}%*"
  else
    filename = " %t"
  end

  local has_icon, file_icon, hl_group = pcall(get_icon)
  if has_icon then
    return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. filename
  else
    return filename
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
      return "  " .. location
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
  -- if you don't have lualine, you can pull this function from:
  -- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/utils/mode.lua
  local mode = require("lualine.utils.mode").get_mode()
  return "%#Mode" .. mode:sub(1, 1) .. "# " .. mode .. " %*"

end

local set_winbar = function()
  if should_skip(true) then
    vim.wo.winbar = nil
  else
    if vim.bo.buftype == "terminal" then
      vim.wo.winbar = "%{%v:lua.winbar.get_mode()%}" .. get_filename()
    else
      vim.wo.winbar = "%{%v:lua.winbar.get_mode()%}" .. get_filename() .. "%#WinBarLocation#%{v:lua.winbar.get_location()}"
    end
  end
end


local id = vim.api.nvim_create_augroup("MyWinBar", { clear = true })
vim.api.nvim_create_autocmd(
  { "BufWinEnter", "BufFilePost", "BufWritePost","BufModifiedSet"},
  { group = id, callback = set_winbar }
)

vim.cmd [[
  highlight WinBar           guifg=#BBBBBB gui=bold
  highlight WinBarLocation   guifg=#888888 gui=bold
  highlight WinBarNC         guifg=#888888 gui=bold
  highlight WinBarModified   guifg=#d7d787


  highlight ModeC guibg=#dddddd guifg=#101010 gui=bold
  highlight ModeI guibg=#ffff5f guifg=#353535 gui=bold
  highlight ModeT guibg=#95e454 guifg=#353535 gui=bold
  highlight ModeN guibg=#8ac6f2 guifg=#353535 gui=bold
  highlight ModeV guibg=#c586c0 guifg=#353535 gui=bold
  highlight ModeR guibg=#f44747 guifg=#353535 gui=bold
]]

_G.winbar = M
return M
