return require('packer').startup(function(use)
    vim = vim
    use {'lewis6991/impatient.nvim', rocks = 'mpack'}
    use 'dstein64/vim-startuptime'
    use 'kyazdani42/nvim-web-devicons'
    use { 'kyazdani42/nvim-tree.lua', opt = true, cmd = 'NvimTree*',
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
                    end
                end
            end
            --vim.g.nvim_tree_disable_keybindings = 1
            vim.g.nvim_tree_disable_default_keybindings = 1
            vim.g.nvim_tree_bindings = {
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
                { key = "I",             cb = tree_cb("toggle_ignored")},
                { key = "h",             cb = tree_cb("toggle_dotfiles")},
                { key = "R",             cb = tree_cb("refresh")},
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
                { key = "H",            cb = "<cmd>tabprevious<cr>"},
                { key = "L",            cb = "<cmd>tabnext<cr>"}
            }
        end
    }
    use 'antoinemadec/FixCursorHold.nvim'
    use 'jlanzarotta/bufexplorer'
    use 'tpope/vim-repeat'
    use 'machakann/vim-sandwich'
    use 'tpope/vim-eunuch'
    use 'airblade/vim-gitgutter'
    use {'junegunn/fzf', dir = '~/.fzf', run = './install --all' }
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

    use 'mfussenegger/nvim-dap'
    use 'rcarriga/nvim-dap-ui'

    use 'mhinz/vim-startify'

    --use {'rrethy/vim-hexokinase',  run = 'make hexokinase' }
    use { 'norcalli/nvim-colorizer.lua', config = function() require'colorizer'.setup() end }
    use 'christianchiarulli/nvcode-color-schemes.vim'

    -- All of the new functionality in neovim 5
    use 'neovim/nvim-lspconfig'
    use {
        'kabouzeid/nvim-lspinstall',
        run = function()
            vim.cmd('LspInstall angular')
            vim.cmd('LspInstall bash')
            vim.cmd('LspInstall csharp')
            vim.cmd('LspInstall css')
            vim.cmd('LspInstall dockerfile')
            vim.cmd('LspInstall go')
            vim.cmd('LspInstall graphql')
            vim.cmd('LspInstall html')
            vim.cmd('LspInstall java')
            vim.cmd('LspInstall json')
            vim.cmd('LspInstall lua')
            vim.cmd('LspInstall python')
            vim.cmd('LspInstall tailwindcss')
            vim.cmd('LspInstall typescript')
            vim.cmd('LspInstall vim')
            vim.cmd('LspInstall yaml')
        end
    }

    use {
        'hrsh7th/nvim-compe',
        opt = true,
        event = 'InsertEnter *',
        config = function()
            require('compe').setup {
                enabled = true;
                autocomplete = true;
                debug = false;
                min_length = 1;
                preselect = 'enable';
                throttle_time = 80;
                source_timeout = 200;
                incomplete_delay = 400;
                max_abbr_width = 100;
                max_kind_width = 100;
                max_menu_width = 100;
                documentation = true;

                source = {
                    path = true;
                    buffer = true;
                    calc = true;
                    nvim_lsp = true;
                    nvim_lua = true;
                    vsnip = true;
                    ultisnips = false;
                };
            }
        end,
        requires = {
            {'SirVer/ultisnips', opt = true, event='InsertEnter' },
            {'honza/vim-snippets', opt = true, event='InsertEnter' },
            {
                'hrsh7th/vim-vsnip',
                opt = true,
                event='InsertEnter',
                config = function ()
                    local t = function(str)
                        return vim.api.nvim_replace_termcodes(str, true, true, true)
                    end

                    local check_back_space = function()
                        local col = vim.fn.col('.') - 1
                        if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                            return true
                        else
                            return false
                        end
                    end

                    -- Use (s-)tab to:
                    --- move to prev/next item in completion menuone
                    --- jump to prev/next snippet's placeholder
                    _G.tab_complete = function()
                        print(vim.fn.pumvisible())
                        if vim.fn.pumvisible() == 1 then
                            return t "<C-n>"
                        elseif vim.fn.call("vsnip#available", {1}) == 1 then
                            return t "<Plug>(vsnip-expand-or-jump)"
                        elseif check_back_space() then
                            return t "<Tab>"
                        else
                            return vim.fn['compe#complete']()
                        end
                    end
                    _G.s_tab_complete = function()
                        print(vim.fn.pumvisible())
                        if vim.fn.pumvisible() == 1 then
                            return t "<C-p>"
                        elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
                            return t "<Plug>(vsnip-jump-prev)"
                        else
                            -- If <S-Tab> is not working in your terminal, change it to <C-h>
                            return t "<S-Tab>"
                        end
                    end

                    vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
                    vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
                    vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
                    vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
                end
            },
            {'hrsh7th/vim-vsnip-integ', opt = true, event='InsertEnter'},
        }
    }

    use {'onsails/lspkind-nvim', opt = true, event='InsertEnter', 
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
    use {'ray-x/lsp_signature.nvim' }
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-fzy-native.nvim'
    use 'jvgrootveld/telescope-zoxide'
    use 'folke/which-key.nvim'
    use 'akinsho/nvim-toggleterm.lua'
    --use 'abecodes/tabout.nvim'
    use { 
        'vuki656/package-info.nvim', 
        opt = true,
        ft = "json",
        requires = { "MunifTanjim/nui.nvim" },
        config = "require('package-info').setup()"
    }
    --use 'lewis6991/gitsigns.nvim'
    use 'pwntester/octo.nvim'


    -- UI Stuff
    use 'psliwka/vim-smoothie'
    use 'shadmansaleh/lualine.nvim'
    --use 'kdheepak/tabline.nvim'

    use 'ryanoasis/vim-devicons'
    use 'lukas-reineke/indent-blankline.nvim'
    use 'gcmt/taboo.vim'
    use 'dstein64/nvim-scrollview'
    use 'cseickel/dwm.vim'

    -- SQL Interface
    use 'tpope/vim-dadbod'
    use 'kristijanhusak/vim-dadbod-ui'

    use 'dkarter/bullets.vim'
end)

