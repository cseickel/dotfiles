-- Auto-close a headless server when no UI is attached.
-- Active only when NVIM_AUTOCLOSE is set (in ms; 0 = close the instant the
-- last client detaches). Normal `nvim` launches skip this entirely.
if vim.env.NVIM_AUTOCLOSE ~= nil then
  local idle_ms   = tonumber(vim.env.NVIM_AUTOCLOSE) or 300000  -- after last client leaves
  local orphan_ms = 30000                                       -- if nobody ever attaches
  local timer

  local function cancel()
    if timer then timer:stop(); timer:close(); timer = nil end
  end

  local function arm(ms)
    cancel()
    timer = vim.uv.new_timer()
    timer:start(ms, 0, function()
      vim.schedule(function()
        if #vim.api.nvim_list_uis() == 0 then
          -- `qall` refuses if buffers are modified -> stay up and retry,
          -- so an idle timeout never silently discards unsaved work.
          if not pcall(vim.cmd, 'qall') then arm(idle_ms) end
        end
      end)
    end)
  end

  arm(orphan_ms)  -- clean up if the server is started but never attached to

  vim.api.nvim_create_autocmd('UIEnter', { callback = function() cancel() end })
  vim.api.nvim_create_autocmd('UILeave', {
    callback = function()
      vim.schedule(function()
        if #vim.api.nvim_list_uis() == 0 then arm(idle_ms) end
      end)
    end,
  })
end
