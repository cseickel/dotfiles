local M = {}


M.winbar_filetype_exclude = {
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


M.get_filename = function()
  local filename = vim.fn.expand "%:t"
  local extension = vim.fn.expand "%:e"

  if not isempty(filename) then
    local file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
      filename,
      extension,
      { default = true }
    )

    local hl_group = "FileIconColor" .. extension

    vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
    if isempty(file_icon) then
      file_icon = ""
      file_icon_color = ""
    end

    return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. "%#WinBarFile#" .. filename .. "%*"
  end
end

M.get_location = function()
  local winid = vim.g.actual_curwin
  if not isempty(winid) then
    local active = winid == tostring(vim.api.nvim_get_current_win())
    if not active then
      return ""
    end
  end
  local status_gps_ok, gps = pcall(require, "nvim-navic")
  if not status_gps_ok then
    return ""
  end
  if not gps.is_available() then
    return ""
  end

  local status_ok, gps_location = pcall(gps.get_location, {})
  if not status_ok or gps_location == "error" then
    return ""
  end

  if not isempty(gps_location) then
    return "  " .. gps_location
  else
    return ""
  end
end

local excludes = function()
  if vim.tbl_contains(M.winbar_filetype_exclude, vim.bo.filetype) then
    vim.opt_local.winbar = nil
    return true
  end
  return false
end

M.get_winbar = function()
  local value = ""
  if not excludes() then
    value = M.get_filename()
    local _, modified = pcall(vim.api.nvim_buf_get_option, 0, "modified")
    if modified then
      value = value .. " %#WinBarModified#%*"
    end
    value = value .. "%#WinBarLocation#%{v:lua.winbar.get_location()}%*"
  end

  local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
  if not status_ok then
    return
  end
end

_G.winbar = M

local id = vim.api.nvim_create_augroup("MyWinBar", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost", "BufWritePost", "BufModifiedSet" }, {
  group = id,
  callback = function()
    require("winbar").get_winbar()
  end,
})

return M
