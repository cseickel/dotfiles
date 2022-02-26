return function()
  require('lspkind').init({
    mode = "symbol_text",
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
