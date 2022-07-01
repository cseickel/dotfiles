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

local get_filename = function()
  local filename = vim.fn.expand "%:t"
  local file_icon = ""
  local hl_group = "WinBarModified"

  if isempty(filename) then
    return ""
  end

  local _, modified = pcall(vim.api.nvim_buf_get_option, 0, "modified")
  if not modified then
    local extension = vim.fn.expand "%:e"
    local file_icon_color = "#ffffff"
    file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
      filename,
      extension,
      { default = true }
    )
    if isempty(file_icon) then
      file_icon = ""
    end
    hl_group = "FileIconColor" .. extension
    vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
  end

  if vim.bo.buftype == "terminal" then
    filename = "TERMINAL #" .. vim.api.nvim_buf_get_number(0)
  end

  return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. "%#WinBarFile#" .. filename .. "%*"
end

M.get_location = function()
  if vim.bo.buftype == "terminal" then
    return  "  " .. vim.b.term_title
  end

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

local set_winbar = function()
  if should_skip(true) then
    vim.wo.winbar = nil
  else
    vim.wo.winbar = get_filename() .. "%#WinBarLocation#%{v:lua.winbar.get_location()}%*"
  end
end


local id = vim.api.nvim_create_augroup("MyWinBar", { clear = true })
vim.api.nvim_create_autocmd(
  { "BufWinEnter", "BufFilePost", "BufWritePost","BufModifiedSet"},
  { group = id, callback = set_winbar }
)

_G.winbar = M
return M
