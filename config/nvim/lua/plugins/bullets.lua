return {
  "dkarter/bullets.vim",
  init = function ()
    vim.g.bullets_enabled_file_types = {
      "markdown",
      "text",
      "gitcommit",
      "gitrebase",
      "gitconfig",
      "gitrebase",
      "gitignore",
      "git",
      "vimwiki",
      "wiki",
    }
  end
}
