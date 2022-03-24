local config = {
  renderers = {
    {
      "container",
      width = "fit_content", --<-- default value for width
      content = {
        {
          "indent",
          zindex = 10,
          indent_size = 2,
          padding = 1, -- extra padding on left hand side,
        },
        { "indent_guide", enabled = true, zindex = 10, align = "right", ... }, -- `...` = the config itself
        { "collapser_icon", enabled = true, zindex = 20, align = "right", ... }, -- `...` = the config itself
      }
    }
  },
  {
    "container",
    width = 2,
    content = {
      { "icon", zindex = 10 },
      { "diagnostics", zindex = 20, show_errors_only = true },
    }
  },
  {
    "container",
    width = "100%", -- <-- means 100% of what's left from the current column to the window width
    comtent = {
      { "name", trailing_slash = false, zindex = 5 },
      { "git_status", enabled = true, zindex = 10, align = "right", symbols = { ... } },
    }
  }
}
