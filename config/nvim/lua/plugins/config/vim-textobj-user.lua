return function(use)
  use {
    'Julian/vim-textobj-variable-segment',
    requires = {
      { 'kana/vim-textobj-user' }
    }
  }

  use {
    'D4KU/vim-textobj-chainmember',
    requires = {
      { 'kana/vim-textobj-user' }
    }
  }
end
