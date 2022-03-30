local log = require("neo-tree.log")
local vim = vim
local M = {}

M.BUFFER_NUMBER = "NeoTreeBufferNumber"
M.CURSOR_LINE = "NeoTreeCursorLine"
M.DIM_TEXT = "NeoTreeDimText"
M.DIRECTORY_ICON = "NeoTreeDirectoryIcon"
M.DIRECTORY_NAME = "NeoTreeDirectoryName"
M.DOTFILE = "NeoTreeDotfile"
M.FADE_TEXT_1 = "NeoTreeFadeText1"
M.FADE_TEXT_2 = "NeoTreeFadeText2"
M.FILE_ICON = "NeoTreeFileIcon"
M.FILE_NAME = "NeoTreeFileName"
M.FILE_NAME_OPENED = "NeoTreeFileNameOpened"
M.FILTER_TERM = "NeoTreeFilterTerm"
M.FLOAT_BORDER = "NeoTreeFloatBorder"
M.FLOAT_TITLE = "NeoTreeFloatTitle"
M.GIT_ADDED = "NeoTreeGitAdded"
M.GIT_CONFLICT = "NeoTreeGitConflict"
M.GIT_DELETED = "NeoTreeGitDeleted"
M.GIT_IGNORED = "NeoTreeGitIgnored"
M.GIT_MODIFIED = "NeoTreeGitModified"
M.GIT_RENAMED = "NeoTreeGitRenamed"
M.GIT_UNTRACKED = "NeoTreeGitUntracked"
M.HIDDEN_BY_NAME = "NeoTreeHiddenByName"
M.INDENT_MARKER = "NeoTreeIndentMarker"
M.NORMAL = "NeoTreeNormal"
M.NORMALNC = "NeoTreeNormalNC"
M.ROOT_NAME = "NeoTreeRootName"
M.SYMBOLIC_LINK_TARGET = "NeoTreeSymbolicLinkTarget"
M.TITLE_BAR = "NeoTreeTitleBar"
M.INDENT_MARKER = "NeoTreeIndentMarker"
M.EXPANDER = "NeoTreeExpander"

local function dec_to_hex(n)
  local hex = string.format("%06x", n)
  if n < 16 then
    hex = "0" .. hex
  end
  return hex
end

---If the given highlight group is not defined, define it.
---@param hl_group_name string The name of the highlight group.
---@param link_to_if_exists table A list of highlight groups to link to, in
--order of priority. The first one that exists will be used.
---@param background string The background color to use, in hex, if the highlight group
--is not defined and it is not linked to another group.
---@param foreground string The foreground color to use, in hex, if the highlight group
--is not defined and it is not linked to another group.
---@gui string The gui to use, if the highlight group is not defined and it is not linked
--to another group.
---@return table table The highlight group values.
local function create_highlight_group(hl_group_name, link_to_if_exists, background, foreground, gui)
  local success, hl_group = pcall(vim.api.nvim_get_hl_by_name, hl_group_name, true)
  if not success or not hl_group.foreground or not hl_group.background then
    for _, link_to in ipairs(link_to_if_exists) do
      success, hl_group = pcall(vim.api.nvim_get_hl_by_name, link_to, true)
      if success then
        local new_group_has_settings = background or foreground or gui
        local link_to_has_settings = hl_group.foreground or hl_group.background
        if link_to_has_settings or not new_group_has_settings then
          vim.cmd("highlight default link " .. hl_group_name .. " " .. link_to)
          return hl_group
        end
      end
    end

    if type(background) == "number" then
      background = dec_to_hex(background)
    end
    if type(foreground) == "number" then
      foreground = dec_to_hex(foreground)
    end

    local cmd = "highlight default " .. hl_group_name
    if background then
      cmd = cmd .. " guibg=#" .. background
    end
    if foreground then
      cmd = cmd .. " guifg=#" .. foreground
    else
      cmd = cmd .. " guifg=NONE"
    end
    if gui then
      cmd = cmd .. " gui=" .. gui
    end
    vim.cmd(cmd)

    return {
      background = background and tonumber(background, 16) or nil,
      foreground = foreground and tonumber(foreground, 16) or nil,
    }
  end
  return hl_group
end

local faded_highlight_group_cache = {}
M.get_faded_highlight_group = function (hl_group_name, fade_percentage)
  if type(hl_group_name) ~= "string" then
    error("hl_group_name must be a string")
  end
  if type(fade_percentage) ~= "number" then
    error("hl_group_name must be a number")
  end
  if fade_percentage < 0 or fade_percentage > 1 then
    error("fade_percentage must be between 0 and 1")
  end
  local key = hl_group_name .. "_" .. tostring(fade_percentage)
  if faded_highlight_group_cache[key] then
    return faded_highlight_group_cache[key]
  end

  local  hl_group = vim.api.nvim_get_hl_by_name(hl_group_name, true)
  if not hl_group.foreground then
    log.debug("hl_group_name must have a foreground color to be faded")
    return hl_group
  end
  
  local foreground = dec_to_hex(hl_group.foreground)
  local red = dec_to_hex(tonumber(foreground:sub(1, 2), 16) * fade_percentage)
  local green = dec_to_hex(tonumber(foreground:sub(3, 4), 16) * fade_percentage)
  local blue = dec_to_hex(tonumber(foreground:sub(5, 6), 16) * fade_percentage)
  local new_foreground = red .. green .. blue

  local new_hl_group = create_highlight_group(key, {}, hl_group.background, new_foreground, hl_group.gui)
  faded_highlight_group_cache[key] = new_hl_group
  return key
end

local key = M.get_faded_highlight_group("Normal", 0.5)
print(vim.inspect(key))
