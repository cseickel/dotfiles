# My Dotfiles

These dotfiles are used to do full stack development using cli tools for most
tasks. The primary tools being tmux, zsh, and neovim. I am currently using this 
to work on typescript, nodejs, graphql, react, aws, etc.

## Fonts

You will need a nerd font to display the special characters correctly. It's not 
required, but it is helpful. I like
[Hack](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Hack).
Do not get a "mono" font, it does not mean "monspaced". All nerd fonts are monospaced,
the "mono" indicator in nerd fonts refers to handling of double wide characters. 
Mono is for compatability with older terminals and will make some icons look too small.

## tmux

The only thing to point here is that the prefix has been changed from the
standard `Ctrl-b` to `Alt-b`. I don't remember why but I'm used to it this way.
To create a new window, `Alt-b c`, switch with `Alt-b <# of window>`, split
with `Alt-b "` and `Alt-b %`, move between split panes with `Alt-b
[<up>|<down>|<left>|<right>]`

See https://tmuxguide.readthedocs.io/en/latest/tmux/tmux.html#basic for more
info.

## zsh

I have a lot of aliases and custom functions defined in [zshrc](zshrc), you
might want to read through that file. 

### git aliases

The highlight is that most git subcommands are aliased so that you can do things 
like `log` instead of `git log`, `checkout` instead of `git checkout`, etc.
Other favorites are `gca` for `git commit -a -m`, `gco` for interactive
branch switching, and `squash`.

If you use Github Issues, `work-on-issue` will allow you to select an issue from
your repo and either create or switch to that branch. New branches will be named
appropriately based on the issue num and title.

## Neovim

This neovim config uses WhichKey, so you can get help on commands as you type
them. My leader is `,`, so starting with that will give you a menu showing most
of my customized comands.

My most commonly used custom commands are:

`<space>` change current word

`;` and `'` to navigate back/forward between files that have been visited within
a window.

`Ctrl-\` to toggle to a terminal.

`,t` to open a terminal at the bottom of the current window.

`h j k l` to navigate between windows.

`\` to toggle a tree navigation. Open a file or `q` to quit.

`|` to open a file tree as a sidebar

`,gd` Go to Definition

`,gr` Go to Reference

`Ctrl-o` jump back

`Ctrl-i` jump forward

`,fg` Grep

`,j` jump to method/function, etc

Block select has been changed to `Alt-v` so as not to conflict with `Ctrl-v`
pasting.

### Copy / Paste

This project uses [svermeulen/vim-cutlass](https://github.com/svermeulen/vim-cutlass)
which will make vim registers behave in a more intuitive (to most) manner. If
you are familiar with traditional vim registers this might be confusing.

Since deletions are sent to the blackhole, "cut" operations use `m` instead.

`m` will cut the selection.

`mm` will cut a line.

#### System clipboard

`Ctrl-c` will copy to the system clipboard on terminals that support OSC-52. I
use Alacritty, Kitty, and Windows Terminal. It also copies to the `c` register.

`Ctrl-v` will paste what has been copied using `Ctrl-c` within vim.

Copy and paste to/from the system clipboard is usually
`Ctrl-shift-c`/`Ctrl-shift-v`.

`Alt-p` is an extra mapping which will paste (`p`) while in insert or terminal mode.


### LSP / Treesitter

LSP Servers, and Debug adapters are set to autoinstall, but you can
manage them using [Mason](https://github.com/williamboman/mason.nvim):
```
:Mason
```

Treesitter is used for syntax highlighting. If you are missing highlighting for
a new file type, type:
```
:TSInstall <tab>
```
and it will autosuggest packages.


### cSpell

[cSpell](https://cspell.org) is enabled. This can be annoying if you are not
willing to maintain a list of allowed words. To do so, add a `cspell.json` file
to the root of every repo. It will use that git root if you are in a git
directory, or just look in the current working directory otherwise.

To configure or disable this, look in
[config/nvim/lua/plugins/config/mason.lua](config/nvim/lua/plugins/config/mason.lua)

vim:tw=80:ts=4
