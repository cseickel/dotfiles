return function(use)
  use {
    "hrsh7th/nvim-cmp",
    opt = true,
    event='InsertEnter',
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      --'hrsh7th/cmp-calc',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
      --'rafamadriz/friendly-snippets',
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      'rcarriga/cmp-dap',
      {
        'David-Kunz/cmp-npm',
        config = function()
          require('cmp-npm').setup()
        end
      },
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup {
        enabled = function ()
          return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
            or require("cmp_dap").is_dap_buffer()
        end,
        formatting = {
          format = function(entry, vim_item)
            -- fancy icons and a name of kind
            vim_item.kind = require("lspkind").presets.default[vim_item.kind]-- .. " " .. vim_item.kind
            -- set a name for each source
            vim_item.menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              vsnip = "[VSnip]",
              nvim_lua = "[Lua]",
              cmp_tabnine = "[TabNine]",
              look = "[Look]",
              path = "[Path]",
              spell = "[Spell]",
              calc = "[Calc]",
              emoji = "[Emoji]",
              npm = "[npm]",
              dap = "[DAP]",
            })[entry.source.name]
            return vim_item
          end
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        snippet = {expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end},
        sources = {
          --{ name = "copilot"},
          --{ name = "nvim_lua" },
          { name = 'nvim_lsp', keyword_length = 1 },
          { name = 'dap' },
          { name = "npm", keyword_length = 3 },
          { name = "vsnip", keyword_length = 1 },
          { name = "path" },
          { name = "calc" },
          { name = 'buffer', keyword_length = 2 },
          --{ name = "nvim_lsp_signature_help" },
        },
        completion = {
          completeopt = 'menu,menuone,noinsert,preview',
          --keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
          --keyword_length = 1,
        },
        preselect = cmp.PreselectMode.None,
      }


      --cmp.setup.cmdline("/", {
      --    mapping = cmp.mapping.preset.cmdline(),
      --    sources = {
      --        { name = "buffer" },
      --    },
      --})

      --cmp.setup.cmdline(":", {
      --    mapping = cmp.mapping.preset.cmdline(),
      --    sources = cmp.config.sources({
      --        { name = "path" },
      --    }, {
      --        { name = "cmdline" },
      --    }),
      --})
    end
  }
end

