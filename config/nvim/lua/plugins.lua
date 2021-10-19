local startup = function(use)
    vim = vim
    use {'lewis6991/impatient.nvim', rocks = 'mpack'}

    use 'dstein64/vim-startuptime'

    use {
        'kyazdani42/nvim-web-devicons',
        config = function ()
            require'nvim-web-devicons'.setup({ default = true })
        end
    }

    use { 'kyazdani42/nvim-tree.lua',
        opt = true,
        cmd = "NvimTree*",
        config = function()
            local tree_cb = require'nvim-tree.config'.nvim_tree_callback
            function _G.open_nvim_tree_selection(targetWindow)
                local lib = require "nvim-tree.lib"
                local node = lib.get_node_at_cursor()
                local windows = {}
                if node then
                    if node.entries ~= nil then
                        lib.unroll_dir(node)
                    else
                        if node.absolute_path then
                            local nonFloatingWindowCount = 0
                            for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
                                if vim.api.nvim_win_get_config(win).relative == "" then
                                    nonFloatingWindowCount = nonFloatingWindowCount + 1
                                    windows[vim.api.nvim_win_get_number(win)] = win;
                                    if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == node.absolute_path then
                                        vim.api.nvim_set_current_win(win)
                                        vim.cmd("call DWM_Focus()")
                                        return
                                    end
                                end
                            end
                            if nonFloatingWindowCount < 2 then
                                vim.cmd("vsplit" .. node.absolute_path)
                            else
                                if targetWindow == "smart" then
                                    -- if there are no windows to the right of the "main" window,
                                    -- then we are not in a tiling layout and we should just reuse
                                    -- that main window.
                                    local treeWidth = vim.api.nvim_win_get_width(windows[1])
                                    local mainWidth = vim.api.nvim_win_get_width(windows[2])
                                    local combinedWidth = treeWidth + 1 + mainWidth
                                    if combinedWidth == vim.o.columns then
                                        targetWindow = "main"
                                    else
                                        targetWindow = "new"
                                    end
                                end
                                if targetWindow == "main" then
                                    vim.cmd("2wincmd w")
                                elseif targetWindow == "new" then
                                    vim.cmd("call DWM_New()")
                                else
                                    error("'" .. targetWindow .. "' is not a valid choice for targetWindow in open_nvim_tree_selection(targetWindow)")
                                end
                                vim.cmd("e " .. node.absolute_path)
                            end
                        else
                            if node.name == [[..]] then
                                vim.cmd("tcd ..")
                            end
                        end
                    end
                end
            end
            local lib = require('nvim-tree.lib')
            require("nvim-tree").setup({
                auto_close = true,
                update_cwd = true,
                update_focused_file = {
                    enable = true
                },
                diagnostics = {
                    enable = true,
                },
                view = {
                    width = 40,
                    mappings = {
                        custom_only = true,
                        list = {
                            { key = "<CR>",           cb = ":lua _G.open_nvim_tree_selection('smart')<cr>" }, -- open in MAIN if one window, or NEW if multiple
                            { key = "<2-LeftMouse>", cb = ":lua _G.open_nvim_tree_selection('smart')<cr>"}, -- open in MAIN if one window, or NEW if multiple
                            { key = "e",             cb = tree_cb("edit")}, -- show window chooserF
                            { key = "n",             cb = ":lua _G.open_nvim_tree_selection('new')<cr>"},  -- open in NEW windowF
                            { key = "m",             cb = ":lua _G.open_nvim_tree_selection('main')<cr>"}, -- open in MAIN windowF
                            { key = "<C-t>",         cb = tree_cb("tabnew")},
                            { key = ".",             cb = tree_cb("cd")},
                            { key = "<BS>",          cb = tree_cb("dir_up")},
                            { key = "<",             cb = tree_cb("prev_sibling")},
                            { key = ">",             cb = tree_cb("next_sibling")},
                            { key = "h",             cb = tree_cb("toggle_dotfiles") },
                            { key = "i",             cb = tree_cb("toggle_ignored") },
                            { key = "R",             cb = tree_cb("refresh") },
                            { key = "a",             cb = tree_cb("create")},
                            { key = "d",             cb = tree_cb("remove")},
                            { key = "r",             cb = tree_cb("rename")},
                            { key = "<C-r>",         cb = tree_cb("full_rename")},
                            { key = "x",             cb = tree_cb("cut")},
                            { key = "c",             cb = tree_cb("copy")},
                            { key = "p",             cb = tree_cb("paste")},
                            { key = "y",             cb = tree_cb("copy_name")},
                            { key = "Y",             cb = tree_cb("copy_path")},
                            { key = "gy",            cb = tree_cb("copy_absolute_path")},
                            { key = "[c",            cb = tree_cb("prev_git_item")},
                            { key = "]c",            cb = tree_cb("next_git_item")},
                            { key = "q",             cb = tree_cb("close")},
                            { key = "-",             cb = ":call SmartWindowResize('v', 0)<cr>"},
                            { key = "=",             cb = ":call SmartWindowResize('v', 1)<cr>"},

                        }
                    }
                }
            })
        end
    }

    use 'antoinemadec/FixCursorHold.nvim'
    use 'jlanzarotta/bufexplorer'
    use 'tpope/vim-repeat'
    use 'machakann/vim-sandwich'
    use 'tpope/vim-eunuch'
    --use 'airblade/vim-gitgutter'
    use {
        'lewis6991/gitsigns.nvim',
        requires = {
            'nvim-lua/plenary.nvim'
        },
        config = function()
            require('gitsigns').setup({
                signs = {
                    add          = {hl = 'GitGutterAdd'   , text = '┃'},
                    change       = {hl = 'GitGutterChange', text = '┃'},
                    delete       = {hl = 'GitGutterDelete', text = '▁'},
                    topdelete    = {hl = 'GitGutterDelete', text = '▔'},
                    changedelete = {hl = 'GitGutterChangeDelete', text = '┻'},
                  },
                  watch_gitdir = {
                    interval = 3000,
                    follow_files = true
                  }
            })
        end
    }

    use { 'junegunn/fzf', dir = '~/.fzf', run = './install --all' }
    use 'junegunn/fzf.vim'
    use { 'sindrets/diffview.nvim', opt = true, cmd = 'DiffviewOpen',
        config = function()
            local cb = require'diffview.config'.diffview_callback
            require'diffview'.setup {
                diff_binaries = false,    -- Show diffs for binaries
                file_panel = {
                    width = 40,
                    use_icons = true        -- Requires nvim-web-devicons
                },
                key_bindings = {
                    disable_defaults = false,                   -- Disable the default key bindings
                    -- The `view` bindings are active in the diff buffers, only when the current
                    -- tabpage is a Diffview.
                    view = {
                        ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
                        ["<down>"]        = cb("next_entry"),
                        ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
                        ["<up>"]          = cb("prev_entry"),
                        ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
                        ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
                    },
                    file_panel = {
                        ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
                        ["<down>"]        = cb("next_entry"),
                        ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
                        ["<up>"]          = cb("prev_entry"),
                        ["<cr>"]          = cb("select_entry"),       -- Open the diff for the selected entry.
                        ["<2-LeftMouse>"] = cb("select_entry"),
                        ["<space>"]       = cb("toggle_stage_entry"), -- Stage / unstage the selected entry.
                        ["a"]             = cb("stage_all"),          -- Stage all entries.
                        ["A"]             = cb("unstage_all"),        -- Unstage all entries.
                        ["R"]             = cb("refresh_files"),      -- Update stats and entries in the file list.
                        ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
                        ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
                    }
                }
            }
        end
    }
    use 'rhysd/conflict-marker.vim'
    use 'nanotee/zoxide.vim'

    use 'svermeulen/vim-easyclip'
    use 'alvan/vim-closetag'
    use 'tmsvg/pear-tree'
    use 'sbdchd/neoformat'

    use {
        'mfussenegger/nvim-dap',
        opt = true,
        keys = { "<F5>", "<F10>", "<F11>", "<F12>", "<leader>b" },
        requires = { 'rcarriga/nvim-dap-ui' },
        config = function ()
            vim.cmd([[
                nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
                nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
                nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
                nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
                nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
            ]])
            require("dapui").setup({
              icons = {
                expanded = "⯆",
                collapsed = "⯈",
                circular = "↺"
              },
              mappings = {
                -- Use a table to apply multiple mappings
                expand = {"<CR>", "<2-LeftMouse>"},
                open = "o",
                remove = "d",
                edit = "e",
              },
              sidebar = {
                elements = {
                  -- You can change the order of elements in the sidebar
                  "scopes",
                  "stacks",
                  "watches"
                },
                size = 40,
                position = "left" -- Can be "left" or "right"
              },
              tray = {
                elements = {
                  "repl"
                },
                size = 10,
                position = "bottom" -- Can be "bottom" or "top"
              },
              floating = {
                max_height = nil, -- These can be integers or a float between 0 and 1.
                max_width = nil   -- Floats will be treated as percentage of your screen.
              }
            })

            local dap = require('dap')
            dap.adapters.netcoredbg = {
              type = 'executable',
              command = '/usr/bin/netcoredbg',
              args = {'--interpreter=vscode'}
            }

            dap.configurations.cs = {
              {
                type = "netcoredbg",
                name = "launch - netcoredbg",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/netcoreapp3.1/', 'file')
                end,
              },
            }
        end
    }

    use 'mhinz/vim-startify'

    --use {'rrethy/vim-hexokinase',  run = 'make hexokinase' }
    use { 'norcalli/nvim-colorizer.lua', config = function() require'colorizer'.setup() end }
    use 'christianchiarulli/nvcode-color-schemes.vim'

    use {
        'williamboman/nvim-lsp-installer',
        requires = {
            'ray-x/lsp_signature.nvim',
            'neovim/nvim-lspconfig'
        },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.completion.completionItem.resolveSupport = {
                properties = {
                    'documentation',
                    'detail',
                    'additionalTextEdits',
                }
            }

            local function lsp_attach()
                require('lsp_signature').on_attach({
                    bind = true,
                    handler_opts = {
                        border = "single"
                    },
                    hint_enable = false,
                    hint_prefix = " ",
                    floating_window = true,
                    toggle_key = "<M-x>"
                })
                --vim.cmd([[
                --  augroup lsp_au
                --  autocmd! * <buffer>
                --  autocmd CursorHoldI <buffer> lua vim.lsp.buf.signature_help()
                --  augroup END
                --  ]], false)
                --
            end
            local opts = {
                capabilities = capabilities,
                on_attach = lsp_attach
            }

            local lsp_installer = require("nvim-lsp-installer")
            lsp_installer.on_server_ready(function(server)
                server:setup(opts)
                vim.cmd [[ do User LspAttachBuffers ]]
            end)
        end,
        run = function()
            vim.cmd('LspInstall angularls')
            vim.cmd('LspInstall bashls')
            vim.cmd('LspInstall omnisharp')
            vim.cmd('LspInstall cssls')
            vim.cmd('LspInstall dockerls')
            vim.cmd('LspInstall gopls')
            vim.cmd('LspInstall graphql')
            vim.cmd('LspInstall html')
            vim.cmd('LspInstall jdtls')
            vim.cmd('LspInstall jsonls')
            vim.cmd('LspInstall sumneko_lua')
            vim.cmd('LspInstall pylsp')
            vim.cmd('LspInstall sqlls')
            vim.cmd('LspInstall tailwindcss')
            vim.cmd('LspInstall tsserver')
            vim.cmd('lspinstall vimls')
            vim.cmd('lspinstall xml')
            vim.cmd('LspInstall yamlls')
        end
    }

    use {
        "hrsh7th/nvim-cmp",
        as = "cmp",
        opt = true,
        event='InsertEnter', 
        requires = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-calc',
            --'SirVer/ultisnips',
            --'honza/vim-snippets',
            'hrsh7th/vim-vsnip',
            'hrsh7th/vim-vsnip-integ',
            'rafamadriz/friendly-snippets'
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup {
                formatting = {
                    format = function(entry, vim_item)
                        -- fancy icons and a name of kind
                        vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind
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
                            emoji = "[Emoji]"
                        })[entry.source.name]
                        return vim_item
                    end
                },
                mapping = {
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                },
                snippet = {expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end},
                sources = {
                    {name = "nvim_lua"},
                    {name = 'nvim_lsp'},
                    {name = "vsnip"},
                    {name = "path"},
                    {name = "calc"},
                    {name = 'buffer', keyword_length = 2},
                },
                completion = {completeopt = 'menu,menuone,noinsert'}
            }
        end
    }

    use {
        'onsails/lspkind-nvim',
        opt = true,
        event='InsertEnter',
        config = function()
            require('lspkind').init({
                with_text = true,
                preset = 'default',
                symbol_map = {
                    Text = '',
                    Method = '',
                    Function = '',
                    Constructor = '',
                    Variable = '',
                    Class = '',
                    Interface = '',
                    Module = '',
                    Property = '',
                    Unit = '',
                    Value = '',
                    Enum = '了',
                    Keyword = '',
                    Snippet = '﬌',
                    Color = '',
                    File = '',
                    Folder = '',
                    EnumMember = '',
                    Constant = '',
                    Struct = '',
                    Operator = ''
                },
            })
        end
    }

    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use {
        'nvim-telescope/telescope.nvim',
        opt = true,
        cmd = "Telescope",
        requires = {
            'nvim-telescope/telescope-fzy-native.nvim',
            'jvgrootveld/telescope-zoxide'
        },
        config = function ()
            require('telescope').setup{
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
                    }
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
              }
            }
            require('telescope').load_extension('fzy_native')
            require'telescope'.load_extension('zoxide')
            require("telescope._extensions.zoxide.config").setup({
              mappings = {
                default = {
                  after_action = function(selection)
                    vim.cmd([[
                        func! OpenFileFinder(timer)
                            lua require('telescope.builtin').find_files()
                        endfunc
                        call timer_start(1, "OpenFileFinder", {'repeat': 1})
                        ]])
                  end
                }
              }
            })
        end
    }

    use {
        'folke/which-key.nvim',
        config = function ()
            require("which-key").setup()
        end
    }

    use {
        'akinsho/nvim-toggleterm.lua',
        opt = true,
        keys = "<C-\\>",
        config = function()
            require("toggleterm").setup{
              open_mapping = [[<c-\>]],
              hide_numbers = true, -- hide the number column in toggleterm buffers
              shade_filetypes = {},
              shade_terminals = true,
              start_in_insert = true,
              direction = 'float',
              persist_size = false,

              close_on_exit = true, -- close the terminal window when the process exits
              shell = vim.o.shell, -- change the default shell
              -- This field is only relevant if direction is set to 'float'
              float_opts = {
                border = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" },
                winblend = 0,
                highlights = {
                  border = "VertSplit",
                  background = "Normal",
                },
                height = function ()
                    return  math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
                end,
                width = function ()
                    return math.ceil(math.min(vim.o.columns, math.max(181, vim.o.columns - 30)))
                end
              }
            }
        end
    }
    --use 'abecodes/tabout.nvim'
    use {
        'vuki656/package-info.nvim',
        requires = { "MunifTanjim/nui.nvim" },
        config = function()
            require('package-info').setup()
        end
    }

    --use 'lewis6991/gitsigns.nvim'


    -- UI Stuff
    use 'psliwka/vim-smoothie'
    use {
        'shadmansaleh/lualine.nvim',
        config = function ()
            local diag_config = {
                'diagnostics',
                -- table of diagnostic sources, available sources:
                -- nvim_lsp, coc, ale, vim_lsp
                sources = { 'nvim_lsp' },
                -- displays diagnostics from defined severity
                sections = {'error', 'warn', 'info', 'hint'},
                -- all colors are in format #rrggbb
                symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}
            }
            require'lualine'.setup {
              options = {
                icons_enabled = true,
                theme = require('lualine-theme'),
                --component_separators = {'|', '|'},
                --section_separators = {'', ''},
                --section_separators = {'', ''},
                --component_separators = {'', ''},
              },
              sections = {
                lualine_a = { {
                        'mode',
                        fmt = function(data)
                            local winwidth = vim.fn.winwidth(0)
                            local filelength = string.len(vim.fn.expand("%:t"))
                            local maxlength = (winwidth - filelength - 17)
                            if maxlength < 1 then
                                return data:sub(1, 1)
                            else
                                return data:sub(1, maxlength)
                            end
                        end
                    }
                },
                lualine_b = { {
                        'filetype',
                        fmt = function(data)
                            local winwidth = vim.fn.winwidth(0)
                            local filelength = string.len(vim.fn.expand("%:t"))
                            local maxlength = (winwidth - filelength - 44)
                            if maxlength < 3 then
                                return nil
                            else
                                return data:sub(1, maxlength)
                            end
                        end
                    }
                },
                lualine_c = { {
                        'filename',
                        path = 1,
                        shorting_target = 40
                    }
                },
                lualine_x = { diag_config },
                lualine_y = { {
                        'branch',
                        fmt = function(data)
                            local winwidth = vim.fn.winwidth(0)
                            local filelength = string.len(vim.fn.expand("%:t"))
                            local maxlength = (winwidth - filelength - 50)
                            if maxlength < 1 then
                                return nil
                            else
                                return data:sub(1,maxlength)
                            end
                        end
                    }
                },
                lualine_z = { {
                        'location',
                        fmt = function(data)
                            local winwidth = vim.fn.winwidth(0)
                            local filelength = string.len(vim.fn.expand("%:t"))
                            local maxlength = (winwidth - filelength - 26)
                            if maxlength < 9 then
                                return nil
                            else
                                return data
                            end
                        end
                    }
                },
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = { 'filetype'},
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = { diag_config },
                lualine_y = { '"WIN #" .. vim.api.nvim_win_get_number(0)' },
                lualine_z = {}
              },
             -- tabline = {
             --       lualine_a = {},
             --       lualine_b = { 'branch' },
             --       lualine_c = {},
             --       lualine_x = { require'tabline'.tabline_tabs },
             --       lualine_y = {},
             --       lualine_z = {},
             -- },
              extensions = { 'nvim-tree', 'quickfix', 'fzf' }
            }
        end
    }
   -- use {
   --     'noib3/cokeline.nvim',
   --     config = function ()
   --         local get_hex = require('cokeline/utils').get_hex

   --         require('cokeline').setup({
   --           hide_when_one_buffer = false,
   --           default_hl = {
   --             focused = {
   --               fg = get_hex('TabLineSel', 'fg'),
   --               bg = get_hex('TabLineSel', 'bg'),
   --               style = 'Bold'
   --             },
   --             unfocused = {
   --               fg = get_hex('TabLine', 'fg'),
   --               bg = get_hex('TabLine', 'bg'),
   --             },
   --           },

   --           components = {
   --             {
   --               text = function(buffer) return ' ' .. buffer.devicon.icon end,
   --               hl = {
   --                 fg = function(buffer) return buffer.devicon.color end,
   --               },
   --             },
   --             {
   --               text = function(buffer) return buffer.filename end,
   --               hl = {
   --                 fg = function(buffer)
   --                   if buffer.lsp.errors ~= 0 then
   --                     return get_hex('LspDiagnosticsSignError', 'fg')
   --                   end
   --                   if buffer.lsp.warnings ~= 0 then
   --                     return get_hex('LspDiagnosticsSignWarning', 'fg')
   --                   end
   --                 end,
   --               },
   --             },
   --             {
   --               text = ' ▕',
   --               delete_buffer_on_left_click = true,
   --             },
   --           },
   --         })

   --     end
   -- }
    use 'gcmt/taboo.vim'

    use 'ryanoasis/vim-devicons'
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = function ()
            require("indent_blankline").setup({
                color_gui = '#303030',
                char = '▏',
                space_char = " ",
                space_char_blank_line = " ",
                show_current_context = true,
                buftype_exclude = { "terminal" },
                filetype_exclude = { "NvimTree", "help", "startify", "packer", "lsp-installer"}
            })
        end
    }

    use 'dstein64/nvim-scrollview'
    use 'cseickel/dwm.vim'

    -- SQL Interface
    use 'tpope/vim-dadbod'
    use 'kristijanhusak/vim-dadbod-ui'

    use 'dkarter/bullets.vim'
    use 'Darazaki/indent-o-matic'
    use {
      'phaazon/hop.nvim',
      as = 'hop',
      config = function()
        -- you can configure Hop the way you like here; see :h hop-config
        require'hop'.setup()
      end
    }
    use 'wellle/targets.vim'
    use {
        'rhysd/clever-f.vim',
        setup = function()
            vim.cmd([[
                let g:clever_f_smart_case=1
                let g:clever_f_show_prompt=1
                let g:clever_f_fix_key_direction=1
                let g:clever_f_chars_match_any_signs=";"
                highlight CleverFDefaultLabel gui=Bold,Underline guifg=#ffaf00
            ]])
        end
    }

    --use {
    --    'ms-jpq/coq_nvim',
    --    branch = "coq",
    --    run = "vim.cmd('COQdeps')",
    --    config = function ()
    --        --require('coq').setup()
    --    end,
    --    requires = {
    --        { 'ms-jpq/coq.artifacts', branch = "artifacts" },
    --        { 'ms-jpq/coq.thirdparty', branch = "3p" }
    --    }
    --}

   -- use {
   --     'GustavoKatel/sidebar.nvim',
   -- --     branch = "dev",
   --     rocks = {'luatz'},
   --     config = function ()
   --         require('sidebar-nvim').setup({
   --             datetime = {
   --                 format = "%a %b %d, %H:%M",
   --                 clocks = {
   --                     { tz = "UTC" },
   --                     { tz = "America/New_York" }
   --                 }
   --             },
   --             side = "right",
   --             docker = {
   --                 show_all = false
   --             },
   --             initial_width = 40,
   --             sections = { "datetime", "git-status", "lsp-diagnostics" }
   --         })
   --     end
   -- }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = {
                    "bash",
                    "c",
                    "c_sharp",
                    "css",
                    "dockerfile",
                    "go",
                    "graphql",
                    "lua",
                    "javascript",
                    "json",
                    "json5",
                    "jsonc",
                    --"html",
                    "java",
                    "typescript",
                    "python",
                    "r",
                    "regex",
                    "scss",
                    "vim",
                    "yaml"
                }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
                highlight = {
                    enable = true,              -- false will disable the whole extension
                    disable = { "html" },  -- list of language that will be disabled
                },
                indent = {
                    enable = true
                }
            }
        end
    }

end

return require('packer').startup({
    startup,
    config = {
        display = {
          open_fn = function()
            return require('packer.util').float({ border = 'single' })
          end
        }
    }
})

