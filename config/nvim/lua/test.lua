local cb = function(...)
  print(...)
end

    local watch_file
    local w = vim.loop.new_fs_event()
    local function on_change(err, fname, status)
      -- Do work...
      print(fname, vim.inspect(status))
      -- Debounce: stop/start.
    end

    function watch_file(fname)
      local fullpath = vim.fn.fnamemodify(fname, ':p')
      w:start(
        fullpath,
        { watch_entry = false, stat = false, recursive = false },
        vim.schedule_wrap(function(...)
          on_change(...)
        end))
    end

    watch_file("~")
