
return function ()
  vim.cmd([[
  nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
  nnoremap <silent> <F8> :lua require'dapui'.toggle()<CR>
  nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
  nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
  nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
  nnoremap <silent> <leader>B :lua require'dap'.toggle_breakpoint()<CR>
  nnoremap <silent> <M-k> <Cmd>lua require("dapui").eval()<CR>
  vnoremap <silent> <M-k> <Cmd>lua require("dapui").eval()<CR>
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
        --"watches"
      },
      size = 40,
      position = "left" -- Can be "left" or "right"
    },
    --tray = {
    --  elements = {
    --    "repl"
    --  },
    --  size = 10,
    --  position = "bottom" -- Can be "bottom" or "top"
    --},
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil   -- Floats will be treated as percentage of your screen.
    }
  })

  require("nvim-dap-virtual-text").setup()

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
        local cwd = vim.fn.getcwd()
        local d = vim.fn.fnamemodify(cwd, ":t")
        return vim.fn.input('Path to dll: ', cwd .. '/bin/Debug/netcoreapp3.1/' .. d .. '.dll', 'file')
      end,
    },
    {
      type = "netcoredbg",
      name = "attach - netcoredbg",
      request = "attach",
      processId = function()
        local pid = require('dap.utils').pick_process()
        vim.fn.setenv('NETCOREDBG_ATTACH_PID', pid)
        return pid
      end,
    },
  }
end
