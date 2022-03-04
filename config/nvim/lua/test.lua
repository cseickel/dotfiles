local Job = require("plenary.job")

Job:new({
  command = "find",
  args = {"/", "-iname", "e"},
  maximum_results = 10,
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
}):start()

