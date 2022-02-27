local Job = require("plenary.job")

Job:new({
  command = "fzf",
  args = {"--no-sort", "--filter", "l"},
  env = { FZF_DEFAULT_COMMAND=""},
  write = "lua",
  on_start = function ()
    print("start")
  end,
  on_stdout = function(_, data, _)
    print(data)
  end,
  on_stderr = function(_, data, _)
    print(data)
  end,
  on_exit = function(_, code, _)
    print("exit", code)
  end,
}):sync()

