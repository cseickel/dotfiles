local function update_title_root()
  local cwd = vim.fn.getcwd(-1, 0)
  local root = vim.fs.root(cwd, ".git") or cwd
  vim.g.title_root = vim.fn.fnamemodify(root, ":t"):upper()
end

update_title_root()

vim.api.nvim_create_autocmd("DirChanged", { callback = update_title_root })

vim.o.titlestring = "%{g:title_root}"
  .. "%{empty(get(g:,'gitsigns_head','')) ? '' : ' [' . g:gitsigns_head . ']'}"
  .. " ... %t"
