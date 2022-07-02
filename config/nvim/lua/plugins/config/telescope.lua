return function ()
  local quickfix_width = function()
    return math.min(vim.o.columns - 2, 180)
  end
  require('telescope').setup({
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case'
      },
      mappings = {
        i = {
          ["<Esc>"] = require('telescope.actions').close,
          ["<C-b>"] = function()
            vim.cmd("close!")
            require('telescope.builtin').file_browser()
          end,
          ["<C-d>"] = function ()
            vim.cmd("close!")
            require('telescope').extensions.zoxide.list()
          end,
          ["<C-f>"] = function()
            vim.cmd("close!")
            require('telescope.builtin').current_buffer_fuzzy_find()
          end,
          ["<C-g>"] = function()
            vim.cmd("close!")
            require('telescope.builtin').live_grep()
          end,
          ["<C-o>"] = function()
            vim.cmd("close!")
            require('telescope.builtin').find_files()
          end,
          ["<C-r>"] = function()
            vim.cmd("close!")
            require('telescope.builtin').oldfiles()
          end,
        }
      },
      pickers = {
        lsp_code_actions = {
          theme = "cursor"
        },
        find_files = {
          hidden = true
        },
      },
      prompt_prefix = "🔍 ",
      selection_caret = " ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
        horizontal = {
          width = { padding = 10 },
          height = { padding = 0.1 },
          preview_width = 0.5,
        },
        vertical = {
          width = { padding = 0.05 },
          height = { padding = 1 },
          preview_height = 0.5,
        }
      },
      extensions = {
        project = {
          hidden_files = true,
          display_type = "full",
        }
      }
    }
  })
  require('telescope').load_extension('fzy_native')
  --require'telescope'.load_extension('zoxide')
  --require("telescope._extensions.zoxide.config").setup({
  --  mappings = {
  --    default = {
  --      after_action = function(selection)
  --        vim.cmd([[
  --        func! OpenFileFinder(timer)
  --          lua require('telescope.builtin').find_files()
  --        endfunc
  --        call timer_start(1, "OpenFileFinder", {'repeat': 1})
  --        ]])
  --      end
  --    }
  --  }
  --})
end
