-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: itchyny(lightline)
-- LuaFormatter off
local colors = {
    gray_darkest = '#353535',
    gray_dark  = '#444444',
    gray_medium  = '#6a6a6a',
    gray_light   = '#bbbbbb',
    almost_black   = '#101010',
    command = "#dddddd",
    insert  = '#cae682',
    --insert = '#dcdcaa',
    replace     = '#f44747',
    normal    = '#8ac6f2',
    terminal   = '#95e454',
    visual   = '#c586c0',
}
-- LuaFormatter on
return {
    normal = {
        a = {
            fg = colors.gray_dark, gui = 'bold',
            bg = colors.normal
        },
        b = {
            fg = colors.gray_light,
            bg = colors.gray_dark
        },
        c = {
            fg = colors.normal, gui = 'bold',
            bg = colors.gray_darkest
        }
    },
    command = {
        a = {
            fg = colors.almost_black, gui = 'bold',
            bg = colors.command
        },
        c = {
            fg = colors.command, gui = 'bold',
            bg = colors.gray_darkest
        }
    },
    insert = {
        a = {
            fg = colors.gray_dark, gui = 'bold',
            bg = colors.insert
        },
        c = {
            fg = colors.insert, gui = 'bold',
            bg = colors.gray_darkest
        }
    },
    visual = {
        a = {
            fg = colors.gray_dark, gui = 'bold',
            bg = colors.visual,
        },
        c = {
            fg = colors.visual, gui = 'bold',
            bg = colors.gray_darkest
        }
    },
    replace = {
        a = {
            fg = colors.gray_darkest, gui = 'bold',
            bg = colors.replace,
        },
        c = {
            fg = colors.replace, gui = 'bold',
            bg = colors.gray_darkest
        }
    },
    terminal = {
        a = {
            fg = colors.gray_darkest, gui = 'bold',
            bg = colors.terminal,
        },
        c = {
            fg = colors.terminal, gui = 'bold',
            bg = colors.gray_darkest
        }
    },
    inactive = {
        a = {
            fg = colors.gray_light, gui = 'bold',
            bg = colors.gray_dark
        },
        c = {
            fg = colors.gray_medium,
            bg = colors.gray_darkest
        }
    }
}
