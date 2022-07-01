return function ()
  local diag_config = {
    'diagnostics',
    -- table of diagnostic sources, available sources:
    -- nvim_lsp, coc, ale, vim_lsp
    sources = { 'nvim_diagnostic' },
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
      section_separators = {'', ''},
      component_separators = { '', '' }
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
      lualine_b = { 
        --{
        --  'filetype',
        --  fmt = function(data)
        --    local winwidth = vim.fn.winwidth(0)
        --    local filelength = string.len(vim.fn.expand("%:t"))
        --    local maxlength = (winwidth - filelength - 44)
        --    if maxlength < 3 then
        --      return nil
        --    else
        --      return data:sub(1, maxlength)
        --    end
        --  end
        --},
        {
          '%{fnamemodify(getcwd(), ":~")}/',
        },
      },
      lualine_c = {
        {
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
      lualine_z = {
        {
          '%3l/%L%  %{LineNoIndicator()} %2c',
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
        },
      },
    },
    --inactive_sections = {
    --  lualine_a = {},
    --  lualine_b = { 'filetype'},
    --  lualine_c = { { 'filename', path = 1 } },
    --  lualine_x = { diag_config },
    --  lualine_y = { '"WIN #" .. vim.api.nvim_win_get_number(0)' },
    --  lualine_z = {}
    --},
    -- tabline = {
    --       lualine_a = {},
    --       lualine_b = { 'branch' },
    --       lualine_c = {},
    --       lualine_x = { require'tabline'.tabline_tabs },
    --       lualine_y = {},
    --       lualine_z = {},
    -- },
    --extensions = { 'nvim-tree', 'quickfix', 'fzf' }
  }
end
