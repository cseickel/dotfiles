vim.o.title = true

local function set_title()
  local cwd = vim.fn.getcwd()
  local root = vim.fs.root(cwd, ".git")
  local place = root and vim.fn.toupper(vim.fs.basename(root))
    or vim.fn.fnamemodify(cwd, ":~")
  -- titlestring treats % as a format code, so a literal % has to be doubled.
  vim.o.titlestring = place:gsub("%%", "%%%%") .. " ❯ nvim"
end

set_title()
vim.api.nvim_create_autocmd("DirChanged", { callback = set_title })
