local M = {}

local isempty = function(s)
	return s == nil or s == ""
end

vim.cmd([[
  highlight WinBar           guibg=None guifg=#BBBBBB gui=bold
  highlight WinBarHeader     guibg=None guifg=#BBBBBB gui=bold,underline
  highlight WinBarNC         guibg=None guifg=#888888 gui=bold
  highlight WinBarLocation   guibg=None guifg=#888888 gui=bold
  highlight WinBarModified   guibg=None guifg=#d7d787
  highlight WinBarGitDirty   guibg=None guifg=#d7afd7
  highlight WinBarIndicator  guibg=None guifg=#5fafd7 gui=bold
  highlight WinBarInactive   guibg=None guibg=#3a3a3a guifg=#777777 gui=bold

  highlight ModeC guibg=#dddddd guifg=#101010 gui=bold " COMMAND
  highlight ModeI guibg=#ffff5f guifg=#353535 gui=bold " INSERT
  highlight ModeT guibg=#95e454 guifg=#353535 gui=bold " TERMINAL
  highlight ModeN guibg=#87d7ff guifg=#353535 gui=bold " NORMAL
  highlight ModeN guibg=#5fafd7 guifg=#262626 gui=bold " NORMAL
  highlight ModeV guibg=#c586c0 guifg=#353535 gui=bold " VISUAL
  highlight ModeR guibg=#f44747 guifg=#353535 gui=bold " REPLACE

  highlight StatusLine              guibg=#303030 guifg=#999999
  highlight StatusLineGit  gui=bold guibg=#3a3a3a guifg=#c586c0
  highlight StatusLineCwd  gui=bold guibg=#3a3a3a guifg=#999999
  highlight StatusLineFile gui=bold guibg=#303030 guifg=#bbbbbb
  highlight StatusLineMod           guibg=#303030 guifg=#d7d787
  highlight StatusLineError         guibg=#303030 guifg=#ff0000
  highlight StatusLineInfo          guibg=#303030 guifg=#87d7ff
  highlight StatusLineHint          guibg=#303030 guifg=#ffffd7
  highlight StatusLineWarn          guibg=#303030 guifg=#d7d700
  highlight StatusLineChanges       guibg=#303030 guifg=#c586c0
  highlight StatusLineOutside       guibg=#3a3a3a guifg=#999999
  highlight StatusLineTransition1   guibg=#303030 guifg=#1c1c1c
  highlight StatusLineTransition2   guibg=#3a3a3a guifg=#1c1c1c

  function! FindHeader()
    " We need to find the header, it will be the first line that has:
    " | columnName |
    " in it.
    " We will only look at the first 100 lines.
    let b:table_header = 1
    for i in range(1, 100)
      let line = getline(i)
      let header = matchstr(line, '|\s.*\s|')
      if !empty(header)
        let b:table_header = i
        return
      endif
    endfor
  endfunction

  augroup dbout
    autocmd!
    autocmd BufReadPost *.dbout call FindHeader()
  augroup END
]])

local winbar_filetype_exclude = {
	[""] = true,
	["NvimTree"] = true,
	["Outline"] = true,
	["Trouble"] = true,
	["alpha"] = true,
	["dashboard"] = true,
	["lir"] = true,
	["neo-tree"] = true,
	["neogitstatus"] = true,
	["packer"] = true,
	["spectre_panel"] = true,
	["startify"] = true,
	["toggleterm"] = true,
}

M.get_neo_tree_context = function()
	local context = require("neo-tree.ui.selector").get_scrolled_off_node_text()
	if isempty(context) then
		return M.active_indicator()
	else
		return context
	end
	--local source = vim.b.neo_tree_source
	--if not isempty(source) then
	--  local label = require("neo-tree").config.source_selector.tab_labels[source]
	--  if not isempty(label) then
	--    return label
	--  end
	--end
	--return ""
end

M.get_header = function()
	local header_line = vim.b.table_header or 1
	-- Sets the winbar to the header line of the buffer, but only if the buffer is
	-- scrolled down so that the header is not visible.
	local view = vim.fn.winsaveview()
	if view.topline <= header_line then
		return nil
	else
		-- get the gutter width
		local winid = vim.api.nvim_get_current_win()
		local wininfo = vim.fn.getwininfo(winid)
		if #wininfo == 0 then
			return nil
		end
		local textoff = wininfo[1].textoff
		local gutter = string.rep(" ", textoff)

		local text = vim.fn.getline(header_line)
		-- remove the first_col - 1 characters from the beginning of the text
		if view.leftcol > 1 then
			text = text:sub(view.leftcol + 1, -1)
		end
		-- add textoff to the beginning of the text
		-- ensure the text is left aligned
		return gutter .. "%#WinBarHeader#" .. text .. "%*%<"
	end
end

M.get_winbar = function()
	-- floating window
	local cfg = vim.api.nvim_win_get_config(0)
	if cfg.relative > "" or cfg.external then
		return ""
	end

	if vim.bo.filetype == "neo-tree" then
		return "%{%v:lua.status.get_neo_tree_context()%}"
	end

	if vim.b.table_header then
		local header = M.get_header()
		if header then
			return header
		end
	end

	if winbar_filetype_exclude[vim.bo.filetype] then
		return "%{%v:lua.status.active_indicator()%}"
	end

	if vim.bo.buftype == "terminal" then
		return "%{%v:lua.status.get_mode()%}%{%v:lua.status.get_icon()%} TERMINAL #%n %#WinBarLocation# %{b:term_title}%*"
	else
		local buftype = vim.bo.buftype
		-- real files do not have buftypes
		if isempty(buftype) then
			return table.concat({
				"%{%v:lua.status.get_mode()%}",
				"%{%v:lua.status.get_filename()%}",
				"%<",
				"%{%v:lua.status.get_location()%}",
				"%=",
				"%{%v:lua.status.get_diag()%}",
				"%{%v:lua.status.get_git_dirty()%}",
			})
		else
			-- Meant for quickfix, help, etc
			return "%{%v:lua.status.get_mode()%}%( %h%) %f"
		end
	end
end

M.get_statusline = function()
	local parts = {
		--"%{%v:lua.status.get_mode()%}",
		'%#StatusLineCwd#  %{fnamemodify(getcwd(), ":~")}/%*',
		"%#StatusLineTransition2#▕%*",
		"%#StatusLineTransition1#▏%*",
		"%<",
		"%#StatusLineFile#%f %*",
		"%#StatusLineMod#%{IsBuffersModified()}%*",
		"%=",
		"%{%v:lua.status.get_diag_counts()%}",
		"%{%v:lua.status.get_git_changes()%}",
		"%#StatusLineTransition1#▕%*",
		"%#StatusLineTransition2#▏%*",
		"%{%v:lua.status.get_git_branch()%}",
		"%#StatusLineOutside# %3l/%L󰮾 %3c %*",
	}
	return table.concat(parts)
end

-- mode_map copied from:
-- https://github.com/nvim-lualine/lualine.nvim/blob/5113cdb32f9d9588a2b56de6d1df6e33b06a554a/lua/lualine/utils/mode.lua
-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local mode_map = {
	["n"] = "NORMAL",
	["no"] = "O-PENDING",
	["nov"] = "O-PENDING",
	["noV"] = "O-PENDING",
	["no\22"] = "O-PENDING",
	["niI"] = "NORMAL",
	["niR"] = "NORMAL",
	["niV"] = "NORMAL",
	["nt"] = "NORMAL",
	["v"] = "VISUAL",
	["vs"] = "VISUAL",
	["V"] = "V-LINE",
	["Vs"] = "V-LINE",
	["\22"] = "V-BLOCK",
	["\22s"] = "V-BLOCK",
	["s"] = "SELECT",
	["S"] = "S-LINE",
	["\19"] = "S-BLOCK",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["ix"] = "INSERT",
	["R"] = "REPLACE",
	["Rc"] = "REPLACE",
	["Rx"] = "REPLACE",
	["Rv"] = "V-REPLACE",
	["Rvc"] = "V-REPLACE",
	["Rvx"] = "V-REPLACE",
	["c"] = "COMMAND",
	["cv"] = "EX",
	["ce"] = "EX",
	["r"] = "REPLACE",
	["rm"] = "MORE",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}

local is_current = function()
	local winid = vim.g.actual_curwin
	if isempty(winid) then
		return false
	else
		return winid == tostring(vim.api.nvim_get_current_win())
	end
end

M.active_indicator = function()
	if is_current() then
		return "%#WinBarIndicator#▔▔▔▔▔▔▔▔%*"
	else
		return ""
	end
end
local icon_cache = {}

M.get_icon = function(filename, extension)
	if not filename then
		if vim.bo.modified then
			return " %#WinBarModified# %*"
			--return " %#WinBarModified#* %*"
		end

		if vim.bo.filetype == "terminal" then
			filename = "terminal"
			extension = "terminal"
		else
			filename = vim.fn.expand("%:t")
		end
	end

	local cached = icon_cache[filename]
	if not cached then
		if not extension then
			extension = vim.fn.fnamemodify(filename, ":e")
		end
		local file_icon, hl_group = require("nvim-web-devicons").get_icon(filename, extension)
		cached = " " .. "%#" .. hl_group .. "#" .. file_icon .. " %*"
		icon_cache[filename] = cached
	end
	return cached
end

M.get_filename = function()
	local has_icon, icon = pcall(M.get_icon)
	if has_icon then
		if vim.b.db_name then
			return icon .. "%t [" .. vim.b.db_name .. "]"
		else
			return icon .. " %t"
		end
	else
		return " %t"
	end
end

local make_two_char = function(symbol)
	if symbol:len() == 1 then
		return symbol .. " "
	else
		return symbol
	end
end

local conf = {
	float = {
		border = "rounded",
	},
	jump = {
		float = false,
		wrap = true,
	},
	severity_sort = false,
	signs = {
		linehl = { "DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint" },
		numhl = { "DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint" },
		text = { " ", " ", " ", " " },
	},
	underline = true,
	update_in_insert = false,
	virtual_lines = false,
	virtual_text = false,
}

local sign_cache = {}
local get_sign = function(severity, icon_only)
	local text, highlight
	local config = vim.diagnostic.config()
  if not config.signs then
    return ""
  end
	if config.signs.text and config.signs.text[severity] then
		text = config.signs.text[severity]
  else
    return ""
	end

	if icon_only then
		return " " .. text
	end

	local cached = sign_cache[severity]
	if cached then
		return cached
	end

	if config.signs.numhl and config.signs.numhl[severity] then
		highlight = config.signs.numhl[severity]
  else
    if severity == vim.diagnostic.severity.ERROR then
      highlight = "DiagnosticSignError"
    elseif severity == vim.diagnostic.severity.WARN then
      highlight = "DiagnosticSignWarn"
    elseif severity == vim.diagnostic.severity.INFO then
      highlight = "DiagnosticSignInfo"
    elseif severity == vim.diagnostic.severity.HINT then
      highlight = "DiagnosticSignHint"
    end
	end
	cached = "%#" .. highlight .. "#" .. text .. "%*"
	sign_cache[severity] = cached
	return cached
end

M.get_diag = function()
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

	return get_sign(min_severity)
end

M.get_diag_counts = function()
	local d = vim.diagnostic.get(0)
	if #d == 0 then
		return ""
	end

	local grouped = {}
	for _, diag in ipairs(d) do
		local severity = diag.severity
		if not grouped[severity] then
			grouped[severity] = 0
		end
		grouped[severity] = grouped[severity] + 1
	end

	local result = ""
	local S = vim.diagnostic.severity
	if grouped[S.ERROR] then
		result = result .. "%#StatusLineError#" .. grouped[S.ERROR] .. get_sign("Error", true) .. "%* "
	end
	if grouped[S.WARN] then
		result = result .. "%#StatusLineWarn#" .. grouped[S.WARN] .. get_sign("Warn", true) .. "%* "
	end
	if grouped[S.INFO] then
		result = result .. "%#StatusLineInfo#" .. grouped[S.INFO] .. get_sign("Info", true) .. "%* "
	end
	if grouped[S.HINT] then
		result = result .. "%#StatusLineHint#" .. grouped[S.HINT] .. get_sign("Hint", true) .. "%* "
	end
	return result
end

M.get_git_branch = function()
	local branch = vim.b.git_branch
	if isempty(branch) then
		return ""
	else
		return "%#StatusLineGit#   " .. branch .. "  %*"
	end
end

M.get_git_changes = function()
	local changes = vim.b.gitsigns_status
	if isempty(changes) then
		return ""
	else
		return "%#StatusLineChanges#" .. changes .. "  %*"
	end
end

M.get_git_dirty = function()
	local dirty = vim.b.gitsigns_status
	if isempty(dirty) then
		return " "
	else
		return "%#WinBarGitDirty# %*"
	end
end

M.get_location = function()
	local success, result = pcall(function()
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

M.get_mode = function()
	if not is_current() then
		--return "%#WinBarInactive# win #" .. vim.fn.winnr() .. " %*"
		return "%#WinBarInactive#  #" .. vim.fn.winnr() .. "  %*"
	end
	local mode_code = vim.api.nvim_get_mode().mode
	local mode = mode_map[mode_code] or string.upper(mode_code)
	return "%#Mode" .. mode:sub(1, 1) .. "# " .. mode .. " %*"
end

vim.cmd([[
  function! GitBranch()
    return trim(system("git -C " . getcwd() . " branch --show-current 2>/dev/null"))
  endfunction

  augroup GitBranchGroup
      autocmd!
      autocmd BufEnter * let b:git_branch = GitBranch()
  augroup END

  " [+] if only current modified, [+3] if 3 modified including current buffer.
  " [3] if 3 modified and current not, "" if none modified.
  function! IsBuffersModified()
      let cnt = len(filter(getbufinfo(), 'v:val.changed == 1'))
      return cnt == 0 ? "" : ( &modified ? "[+". (cnt>1?cnt:"") ."]" : "[".cnt."]" )
  endfunction
]])

_G.status = M
vim.o.winbar = "%{%v:lua.status.get_winbar()%}"
vim.o.statusline = "%{%v:lua.status.get_statusline()%}"

return M
