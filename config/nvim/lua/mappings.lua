local memory_utils = pcall(require, "memory_utils")

local showSymbolFinder = function()
  local preview_width = vim.o.columns - 20 - 65
  if preview_width < 80 then
    preview_width = 80
  end
  local opts = {
    symbols = {
      "interface",
      "class",
      "constructor",
      "method",
      "type",
    },
    entry_maker = require("telescope-custom").gen_from_lsp_symbols(),
    layout_config = {
      width = { padding = 10 },
      preview_width = preview_width,
    },
  }
  if string.match(vim.bo.filetype, "script") then
    opts.symbols = {
      "interface",
      "class",
      "constructor",
      "method",
      "type",
      "function",
      "constant",
      "variable",
    }
  end
  if vim.bo.filetype == "vim" or vim.bo.filetype == "lua" then
    opts.symbols = { "function" }
  end
  require("telescope.builtin").lsp_document_symbols(opts)
end

local getQuickfixOptions = function()
  local width = math.min(vim.o.columns - 2, 180)
  local height = math.min(vim.o.lines - 10, 60)
  local opt = {
    jump_type = "never",
    layout_strategy = "vertical",
    layout_config = {
      width = width,
      height = height,
    },
    entry_maker = require("telescope-custom").gen_from_quickfix({ width = width }),
  }
  return opt
end

local showDefinition = function()
  require("telescope.builtin").lsp_definitions(getQuickfixOptions())
end

local showImplementation = function()
  require("telescope.builtin").lsp_implementations(getQuickfixOptions())
end

local showReferences = function()
  require("telescope.builtin").lsp_references(getQuickfixOptions())
end

local showType = function()
  require("telescope.builtin").lsp_type_definitions(getQuickfixOptions())
end

local openNeotree = function()
  local cmd = require("neo-tree.command")
  local manager = require("neo-tree.sources.manager")
  cmd.execute({
    action = "focus",
    source = "filesystem",
    position = "current",
  })
  local tabnr = vim.api.nvim_get_current_tabpage()
  local winid = vim.api.nvim_get_current_win()
  local state = manager.get_state("filesystem", tabnr, winid)
  return state
end

local findDirectory = function()
  local filter = require("neo-tree.sources.filesystem.lib.filter")
  local state = openNeotree()
  filter.show_filter(state, true, "directory")
end

local findFile = function()
  local filter = require("neo-tree.sources.filesystem.lib.filter")
  local state = openNeotree()
  filter.show_filter(state, true, true)
end

local getProjectRoot = function()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

grep_args = {
  "-g", "!node_modules/",
  "-g", "!dist/",
  "-g", "!build/",
  "-g", "!codegen/",
  "-g", "!generated/",
}

local grepProject = function()
  require("telescope.builtin").live_grep({
    cwd = getProjectRoot(),
    additional_args = grep_args,
  })
end

local grepCWD = function()
  require("telescope.builtin").live_grep({
    cwd = vim.fn.getcwd(0, 0),
    additional_args = grep_args,
  })
end

local mappings = {
  [";"] = { "<Plug>(buf-surf-back)", "Previous Buffer" },
  ["'"] = { "<Plug>(buf-surf-forward)", "Next Buffer" },
  h = { "Focus window to the LEFT" },
  j = { "Focus window BELOW" },
  k = { "Focus window ABOVE" },
  l = { "Focus window to the RIGHT" },
  H = { "Start of Line" },
  L = { "End of Line" },
  K = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show documentation" },
  ["\\"] = { "<cmd>Neotree current reveal toggle<cr>", "Open Tree in Current Window" },
  ["|"] = { "<cmd>Neotree reveal<cr>", "Open Tree in Sidebar" },
  ["["] = {
    name = "Previous...",
    c = { "<cmd>ConflictMarkerPrevHunk<cr>", "Previous Conflict" },
    d = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous Diagnostic" },
    e = { "<cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR})<cr>", "Previous ERROR Diagnostic" },
    h = { "<cmd>Gitsigns prev_hunk<cr>", "Previous Git Hunk" },
    --h = { "<Plug>(GitGutterPrevHunk)", "Previous Git Hunk" },
    l = { "<cmd>lprevious<bar>normal z.<cr>", "Previous Location List" },
    q = { "<cmd>cprevious<bar>normal z.<cr>", "Previous Quickfix" },
  },
  ["]"] = {
    name = "Next...",
    c = { "<cmd>ConflictMarkerNextHunk<cr>", "Next Conflict" },
    d = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
    e = { "<cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR})<cr>", "Next ERROR Diagnostic" },
    h = { "<cmd>Gitsigns next_hunk<cr>", "Next Git Hunk" },
    --h = { "<Plug>(GitGutterNextHunk)", "Next Git Hunk" },
    l = { "<cmd>lnext<bar>normal z.<cr>", "Next Location List" },
    q = { "<cmd>cnext<bar>normal z.<cr>", "Next Quickfix" },
  },
  ["<leader>"] = {
    ["o"] = {
      name = "Octo Context Actions...",
      a = { "Assignee..." },
      c = { "Comment..." },
      l = { "Label..." },
      r = { "React..." },
    },
    i = { "<cmd>Octo issue list is:open assignee:cseickel<cr>", "My Open Issues" },
    ["."] = { "Set Working Directory from current file" },
    ["="] = { "<cmd>Format<cr>", "Format Document" },
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code actions" },
    b = { "<cmd>Neotree reveal buffers current<cr>", "Show Buffers Tree" },
    c = {
      name = "Conflict Resolution",
      b = { "<cmd>ConflictMarkerBoth<cr>", "Keep Both" },
      o = { "<cmd>ConflictMarkerOurselves<cr>", "Keep Ourselves (Top/HEAD)" },
      n = { "<cmd>ConflictMarkerOurselves<cr>", "Keep None" },
      t = { "<cmd>ConflictMarkerThemselves<cr>", "Keep Themselves (Bottom)" },
    },
    d = {
      name = "Diagnostics...",
      d = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Preview Diagnostic" },
      E = { "<cmd>lua vim.diagnostic.enable()<cr>", "Enable Diagnostics" },
      e = { "<cmd>lua vim.diagnostic.disable()<cr>", "Disable Diagnostics" },
      s = { "<cmd>Neotree diagnostics<cr>", "Show Neotree Diagnostics" },
      w = { "<cmd>lua require('diagnostic-window').show()<cr>", "Show Line Diagnostics in Split" },
      l = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Set Location List (Diagnostics for Document)" },
      q = { "<cmd>lua vim.diagnostic.setqflist()<cr>", "Set Quickfix List (Diagnostics for Workspace)" },
    },
    D = { "<cmd>Neotree diagnostics reveal bottom<cr>", "Show all Diagnostics" },
    j = { showSymbolFinder, "Jump to Method, Class, etc" },
    -- J = { "f,ls<cr><esc>", "Newline at next comma" },
    J = { "<cmd>TSJToggle<cr>", "Toggle Split/Join" },
    q = { "Show Quickfix" },
    Q = { "Close Quickfix" },
    f = {
      name = "File...", -- optional group name
      d = { findDirectory, "Directory picker (neo-tree)" },
      -- f = { findFile, "Find File (neo-tree)" },
      f = { "<cmd>lua require('telescope').extensions.smart_open.smart_open()<CR>", "Find File (smart_open)" },
      c = { grepCWD, "Grep CWD" },
      g = { grepProject, "Grep Project (git root)" },
    },
    g = {
      name = "Go to...",
      d = { showDefinition, "Go to Definition" },
      i = { showImplementation, "Go to Implementation" },
      r = { showReferences, "Find References" },
      t = { showType, "Go to Type Definition" },
    },
    n = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename symbol" },
    ["?"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show signature help" },
    h = {
      name = "Gitsigns Hunk...",
      p = { "<cmd>Gitsigns preview_hunk<cr>", "Preview Hunk" },
      r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk" },
      R = { "<cmd>Gitsigns reset_buffer<cr>", "Reset Buffer" },
      --r = { "<Plug>(GitGutterUndoHunk)", "Reset Hunk" },
      --R = { "<cmd>!git checkout -- %<cr>", "Reset Buffer" },
    },
    --m = {
    --  name = "Memory Leak...",
    --  b = { memory_utils.capture_before,                       "Capture Before" },
    --  a = { memory_utils.capture_after,                        "Capture After" },
    --  c = { memory_utils.compare,                              "Compare" },
    --},
    r = { '<cmd>lua require("spectre").open()<CR>', "Search and Replace" },
    s = { "<cmd>Neotree reveal git_status current<cr>", "Show Git Status" },
    t = { "Open  Terminal" },
    T = { "Close Terminal" },
    z = { ":call ToggleWindowZoom(0)<cr>", "Zoom Window (toggle)" },
    Z = { ":call ToggleWindowZoom(1)<cr>", "Zoom Window in Copy Mode (no decorations)" },
    w = {
      name = "Switch to window...",
      ["1"] = { "Switch to window 1" },
      ["2"] = { "Switch to window 2" },
      ["3"] = { "Switch to window 3" },
      ["4"] = { "Switch to window 4" },
      ["5"] = { "Switch to window 5" },
      ["6"] = { "Switch to window 6" },
      ["7"] = { "Switch to window 7" },
      ["8"] = { "Switch to window 8" },
      ["9"] = { "Switch to window 9" },
      ["0"] = { "Switch to window 10" },
    },
  },
}
require("which-key").register(mappings)

vim.cmd([[
  vnoremap <leader>r <esc><cmd>lua require("spectre").open_visual()<CR>
  vnoremap = <cmd>Format<cr>

  imap <silent><script><expr> <C-j> copilot#Accept("\<C-j>")
  imap <silent><script><expr> <RIGHT> copilot#Accept("\<RIGHT>")
  let g:copilot_no_tab_map = v:true


  function! ToggleWindowZoom(clear_decorations) abort
      if exists("b:is_zoomed_win") && b:is_zoomed_win
          unlet b:is_zoomed_win
          let l:name = expand("%:p")
          let l:top = line("w0")
          let l:line = line(".")
          tabclose
          let windowNr = bufwinnr(l:name)
          if windowNr > 0
              execute windowNr 'wincmd w'
              execute "normal " . l:top . "zt"
              execute l:line
          endif
      else
          if winnr('$') > 1 || a:clear_decorations
              let l:top = line("w0")
              let l:line = line(".")
              -1tabedit %
              let b:is_zoomed_win = 1
              execute "normal " . l:top . "zt"
              execute l:line
              execute "TabooRename  " . expand("%:t")
          endif
          if a:clear_decorations
              set nonumber
              set signcolumn=no
              IndentBlanklineDisable
          endif
      endif
  endfunction


  function! InitSql(dburl)
    let b:db=a:dburl
    nnoremap <silent><buffer> <M-x> <cmd>call ExecuteSql(0)<cr>
    vnoremap <silent><buffer> <M-x> <cmd>call ExecuteSql(1)<cr>
  endfunction

  function! ExecuteSql(visual)
    if b:db == ""
      let b:db = $DBUI_URL
    endif
    if b:db == ""
      let b:db=input("Enter DB URL: ")
    endif
    if a:visual
      call execute('DB ' . b:db)
    else
      call execute('%DB ' . b:db)
    endif
  endfunction

  function! Highlight_Symbol() abort
      if &ft != "cs"
          lua vim.lsp.buf.document_highlight()
      endif
  endfunction


  augroup plugin_mappings_augroup
      autocmd!
      autocmd CursorHold * silent! call Highlight_Symbol()
      autocmd CursorMoved * silent! lua vim.lsp.buf.clear_references()
      autocmd FileType sql call InitSql("")
  augroup END
]])
