local buf = vim.api.nvim_create_buf(true, false)
local data = {}
for i = 1, 20 do
  table.insert(data, "Line " .. i)
end
vim.api.nvim_buf_set_lines(buf, 0, -1, true, data)
vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')
vim.cmd([[call prompt_setprompt(]] .. buf .. [[, 'Filter: ')]])

_G.Prompt_Callback = function(input)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local filtered = {}
  for _, line in ipairs(data) do
    if line:find(input) then
      table.insert(filtered, line)
    end
  end
  vim.schedule(function()
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, filtered)
  end)
end
vim.cmd([[
  let g:prompt_filter = ""
  function! Prompt_Callback(input)
    let g:prompt_filter = a:input
    execute("lua _G.Prompt_Callback('" . a:input . "')")
    stopinsert
  endfunction

  function! Prompt_CharCallback()
    let g:prompt_filter = g:prompt_filter . v:char 
    execute("lua _G.Prompt_Callback('" . g:prompt_filter . "')")
  endfunction
]])
vim.cmd([[call prompt_setcallback(]] .. buf .. [[, function("Prompt_Callback"))]])
vim.api.nvim_win_set_buf(0, buf)
vim.cmd("startinsert")
vim.cmd([[
  augroup Prompt_Callback
    au!
    au InsertCharPre <buffer> call Prompt_CharCallback()
  augroup END
]])
