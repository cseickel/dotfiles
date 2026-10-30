# Work environment

The work environment is a terminal setup that Nix builds from `/home/chris/dotfiles`. Any machine with Nix can rebuild it from that repo.

It has three parts:

- **`/home/user`** is a separate home that home-manager builds. It holds the packages listed in `/home/chris/dotfiles/nix/packages.txt`, and links to the zsh, git, nvim and starship configs in `/home/chris/dotfiles`.
- **`work-shell`** runs zsh in a bubblewrap sandbox. Inside it, `/home/user` is the home and the host's `/usr` is hidden.
- **`pkg`** searches nixpkgs and installs the packages you pick, from inside the work shell.

Hiding `/usr` is the point of the sandbox. A tool that isn't declared fails right away, instead of quietly running Fedora's copy.

The desktop stays outside all of this. GUI apps can be installed any way, the distro can change, and none of it is reproduced.

A Docker dev container also hid undeclared tools. It brought Docker-in-Docker, UID and mount problems, and an image rebuild for every new tool.

## Status

The work environment is on trial on branch `home-manager-test`. It runs alongside the dotbot setup in `/home/chris`, which it doesn't change. The desktop configs (niri, DankMaterialShell, kitty, fonts) stay with dotbot and aren't managed here.

It is tested on Fedora 44 with the Fedora nix RPM (nix 2.35, nix-daemon). See [Known gaps](#known-gaps) for what doesn't work yet, and [Switch permanently or abandon](#switch-permanently-or-abandon) to end the trial.

## Set up

These are the prerequisites:

- Multi-user Nix, meaning a running nix-daemon, with `nix-command` and `flakes` enabled. The work shell mounts `/nix` read-only and builds through the daemon, so a single-user install won't work inside it. The Fedora nix RPM and the Determinate installer both qualify.
- `/home/user`, owned by you:

  ```sh
  sudo mkdir /home/user && sudo chown chris:chris /home/user
  ```

- The dotfiles repo cloned at `/home/chris/dotfiles`.

The username `chris`, the host home `/home/chris`, the home `/home/user` and the system `x86_64-linux` are set in `layout` in `/home/chris/dotfiles/flake.nix`. On a machine where any of those differ, edit them first.

Bootstrap with this command, run from any host shell:

```sh
nix run /home/chris/dotfiles#work-shell -- -c '"$(nix build --no-link --print-out-paths /home/chris/dotfiles#homeConfigurations.chris.activationPackage)"/activate'
```

The command does two things:

1. It builds the home-manager activation package. That package is the built home plus an `activate` script that links it into place.
2. It runs that `activate` script inside the work shell. Activation writes to `$HOME`, and `$HOME` is `/home/user` only inside the work shell.

Then, inside the work shell, log in to GitHub once. The GitHub credential helper in `/home/chris/dotfiles/gitconfig` calls `gh`, and `gh` keeps its login in `/home/user/.config/gh`, which starts empty:

```sh
gh auth login
```

Then point `/home/user/.local/bin/claude` at an installed Claude Code version and log in. The versions live in `/home/chris/.local/share/claude/versions`, which the work shell can see, and `claude-use` comes from `/home/chris/claude-instructions/scripts/shell-init.sh`:

```sh
claude-use            # lists the installed versions
claude-use <version>
claude                # asks you to log in the first time
```

## Use

### Enter the work shell

```sh
/home/user/.nix-profile/bin/work-shell
```

It starts in the directory you ran it from when that directory is under `/home/user` or a `hostPaths` entry, and in `/home/user` otherwise. `exit` returns to the host shell. Arguments go to zsh, so these run one command inside from outside:

```sh
/home/user/.nix-profile/bin/work-shell -c '<command>'      # reads /home/user/.zshenv only
/home/user/.nix-profile/bin/work-shell -i -c '<command>'   # reads /home/user/.zshenv and /home/user/.zshrc
/home/user/.nix-profile/bin/work-shell -f -c '<command>'   # reads no startup files
```

### Add a package

```sh
pkg <search terms>
```

`pkg` runs these steps:

1. It searches the nixpkgs version locked in `/home/chris/dotfiles/flake.lock`, which is the same package set a switch installs.
2. It lists the matches in fzf. Tab selects a package, and Enter confirms.
3. It adds the selected names to `/home/chris/dotfiles/nix/packages.txt`.
4. It runs `home-manager switch`. If the switch fails, it restores `/home/chris/dotfiles/nix/packages.txt` to what it was.

It doesn't commit.

The first search after a `nix flake update` is slow, because Nix evaluates all of nixpkgs. Later searches come from Nix's cache.

`/home/chris/dotfiles/nix/packages.txt` holds one nixpkgs attribute per line, kept sorted. Nested attributes such as `ghostty.terminfo` work. After editing it by hand, apply the change with:

```sh
home-manager switch --flake /home/chris/dotfiles
```

The new commands appear in open work shells as soon as the switch finishes.

### Edit dotfiles

The dotfiles are linked straight to `/home/chris/dotfiles` with out-of-store links. An out-of-store link points at the file in the working tree, so an edit takes effect immediately and git tracks it. A normal home-manager link points at a read-only copy in the Nix store instead. These files are the same ones the dotbot setup links into `/home/chris`, so a change applies to the host shell too.

### Update nixpkgs

```sh
nix flake update --flake /home/chris/dotfiles
home-manager switch --flake /home/chris/dotfiles
```

Then commit `/home/chris/dotfiles/flake.lock`. If something breaks, restore the old lock file and switch again:

```sh
git -C /home/chris/dotfiles checkout flake.lock
home-manager switch --flake /home/chris/dotfiles
```

### Undo a switch

Each switch creates a generation, a numbered snapshot of the home. To go back to an earlier one, list them and run the `activate` script of the one you want:

```sh
home-manager generations
/nix/store/<hash>-home-manager-generation/activate
```

A rollback has two limits:

- The next switch, including the one `pkg` runs, builds from the repo again. Also revert the repo change that caused the problem, such as the edit to `/home/chris/dotfiles/nix/packages.txt` or `/home/chris/dotfiles/flake.lock`.
- The dotfiles stay as they are, because they are out-of-store links. Use git to revert them.

## Known gaps

None of the likely fixes below have been tested.

| Gap | Cause | Likely fix |
|---|---|---|
| Claude Code's global config differs inside | `/home/chris/.claude` is shared, but `/home/user/.claude.json` is a separate file from `/home/chris/.claude.json`. It isn't linked, because Claude Code rewrites it and might replace a link with a plain file. | Check whether Claude Code keeps a symlinked `.claude.json` intact. If it does, add `.claude.json` to `hostPaths`. |
| The command server's `nvim` command fails inside | Its definition runs `${HOME}/AppImages/nvim-extracted/AppRun` (`/home/chris/claude-instructions/mcp-servers/src/command/definitions.ts:272`), and `/home/user/AppImages` doesn't exist | In that definition, run `nvim` from PATH and make the AppImage bind a `--ro-bind-try`. The host's `nvim` on PATH is the AppImage, so the host keeps working. |
| nvim DAP adapters may fail | `mason-nvim-dap` (`/home/chris/dotfiles/config/nvim/lua/plugins/nvim-dap.lua:24`) downloads them when nvim-dap loads. They should run through nix-ld, and none has been installed inside yet. | Check the first time nvim-dap loads. Add any library one needs to `nixLdLibraries`. |
| coderabbit and leaf are missing | They were installed by hand on the host | Run their own installers inside the work shell. They land in `/home/user/.local/bin` and run through nix-ld. |
| Hand installs go unreported | `drift` isn't built. Anything installed by hand lands in `/home/user` and survives. | Build `drift` |

## Switch permanently or abandon

### Switch permanently

1. Merge `home-manager-test` into `main`.
2. Create `/home/chris/.config/ghostty/config` with this line, so every new Ghostty window opens the work shell:

   ```
   command = /home/user/.nix-profile/bin/work-shell
   ```

3. Rewrite [Status](#status) to describe the result.

dotbot keeps managing `/home/chris`, and the host shell still uses its zsh and git links, so nothing comes out of `/home/chris/dotfiles/install.conf.yaml`. For a host shell, run `ghostty -e /usr/bin/zsh` from the desktop launcher. Untested.

### Abandon

These steps assume the trial is committed on `home-manager-test`. Uncommitted changes follow `git switch` to `main`. Leave every open work shell first, then run:

```sh
find /home/user -mindepth 1 -maxdepth 1 -exec rm -rf {} +
sudo rmdir /home/user
git -C /home/chris/dotfiles switch main
git -C /home/chris/dotfiles branch -D home-manager-test
nix-collect-garbage
```

`find` passes each name without a trailing slash, so `rm` deletes the symlinks to `/home/chris` and doesn't follow them. The garbage-collection roots for the home live under `/home/user/.local/state`. Once that's gone, `nix-collect-garbage` drops them and frees the store paths. Nothing else stays behind.

## How it works

### The sandbox

`work-shell` (`/home/chris/dotfiles/nix/work-shell.nix`) starts zsh inside bubblewrap with this view of the filesystem:

| Path inside | Comes from | Why |
|---|---|---|
| `/home/user` | host `/home/user`, read-write | the home |
| each `layout.hostPaths` entry, e.g. `/home/chris/repos` | the same host path, read-write | so paths match inside and outside |
| `/nix` | host, read-only | packages, and the daemon socket for builds |
| `/tmp`, `/var/tmp` | host, read-write | shared scratch, the same paths outside |
| `/run/user/<uid>` | host, read-write | Wayland, D-Bus, the systemd user manager |
| `/run/docker.sock` | host | the host's Docker daemon |
| `/dev` | host | |
| `/proc` | a new procfs, which still shows the host's processes | |
| `/sys` | host, read-only | |
| `/bin/sh`, `/usr/bin/env` | symlinks into the Nix store | the only two paths scripts assume, as on NixOS |
| `/lib64/ld-linux-x86-64.so.2` | nix-ld from nixpkgs | the loader prebuilt binaries ask for, as on NixOS |
| `/etc` | a few files, listed below | |

The rest of the host is hidden, including `/usr`, the host's `/lib64` and the rest of `/home/chris`.

`/etc` holds only these files:

- From the host, read-only: `/etc/passwd`, `/etc/group`, `/etc/hosts`, `/etc/machine-id`, `/etc/resolv.conf` (resolved to its real file), and `/etc/nix`, which holds the daemon's `nix.conf`.
- `/etc/nsswitch.conf` is generated, with `files` and `dns` only. Fedora's names NSS modules such as `systemd`, `myhostname` and `resolve`, which load from the hidden `/usr/lib64`.
- `/etc/ssl/certs/ca-certificates.crt` links to the nixpkgs CA bundle.

Hiding `/usr` has these consequences:

- A shebang like `#!/bin/bash` or `#!/usr/bin/python3` fails. Use `#!/usr/bin/env bash`.
- A prebuilt binary, such as one an installer or an nvim plugin downloads, asks for `/lib64/ld-linux-x86-64.so.2`. That path is nix-ld, which loads the binary with the nixpkgs glibc and the libraries in `nixLdLibraries` (`/home/chris/dotfiles/nix/work-shell.nix`). A binary that needs a library missing from that list fails until the library is added.
- The host's `nix` client lives under `/usr`, so the work shell puts the nixpkgs `nix` on PATH, which builds through the host's daemon.
- Host programs can't run inside. `xdg-open` is a shim that asks the host's systemd user manager to run the host's `gio open` with `systemd-run --user --same-dir`, so a relative path resolves from the current directory. `gio` honors `Terminal=true` in desktop files under niri, where xdg-utils doesn't.

The environment starts empty. The work shell sets these variables:

| Variable | Value |
|---|---|
| `HOME` | `/home/user` |
| `USER`, `LOGNAME` | your username |
| `SHELL` | the nixpkgs zsh |
| `PATH` | `/home/user/.nix-profile/bin`, then the nixpkgs nix client |
| `TERMINFO_DIRS` | `/home/user/.nix-profile/share/terminfo` |
| `LOCALE_ARCHIVE` | an `en_US.UTF-8` locale archive from nixpkgs |
| `TZ`, `TZDIR` | the host's time zone, and the nixpkgs zone database |
| `SSL_CERT_FILE`, `NIX_SSL_CERT_FILE` | the nixpkgs CA bundle |
| `NIX_LD`, `NIX_LD_LIBRARY_PATH` | the nixpkgs glibc loader and the `nixLdLibraries`, which nix-ld reads |
| `WORK_SHELL` | `1`, so `/home/chris/dotfiles/zshrc` can tell it's running inside |

These pass through from the host when the host has them set:

- Terminal: `TERM`, `COLORTERM`, `TERM_PROGRAM`, `TERM_PROGRAM_VERSION`, `LANG`
- Display: `WAYLAND_DISPLAY`, `DISPLAY`, `XDG_SESSION_TYPE`, `XDG_CURRENT_DESKTOP`
- Session: `XDG_RUNTIME_DIR`, `DBUS_SESSION_BUS_ADDRESS`, `SSH_AUTH_SOCK`

Docker bind mounts work for any path inside that exists at the same path on the host: `/home/user`, the `hostPaths` and `/tmp`. The host's daemon resolves the path in the host's filesystem.

The sandbox keeps undeclared tools out. It doesn't keep a process inside from acting on the host. `/run/user/<uid>` gives access to the systemd user manager and the session bus, and `/run/docker.sock` is equivalent to root.

### The home

home-manager (`/home/chris/dotfiles/nix/home.nix`) builds `/home/user` from three parts:

- **Links to the host.** Each `layout.hostPaths` entry becomes a link, such as `/home/user/repos` → `/home/chris/repos`. The same list drives the binds in the sandbox, so every link resolves both inside and on the host.
- **Links to the dotfiles.** These are out-of-store links into `/home/chris/dotfiles`:

  | Link | Target |
  |---|---|
  | `/home/user/.zshrc` | `/home/chris/dotfiles/zshrc` |
  | `/home/user/.zshenv` | `/home/chris/dotfiles/zshenv` |
  | `/home/user/.gitconfig` | `/home/chris/dotfiles/gitconfig` |
  | `/home/user/.visidatarc` | `/home/chris/dotfiles/visidatarc` |
  | `/home/user/.config/nvim` | `/home/chris/dotfiles/config/nvim` |
  | `/home/user/.config/starship.toml` | `/home/chris/dotfiles/config/starship.toml` |

  The zshrc finds oh-my-zsh at `/home/user/.oh-my-zsh`, which links to the nixpkgs copy.
- **`/home/user/.local/bin/edit.sh`**, the `$EDITOR` the zshrc sets. It runs `nvim` in the current terminal. The zshrc writes its own host version, which opens kitty, only when the file is missing.
- **Packages.** Everything in `/home/chris/dotfiles/nix/packages.txt`, plus `work-shell`, `pkg` and the `xdg-open` shim, which are built in `/home/chris/dotfiles/nix`.

home-manager writes `home.sessionVariables` to `/home/user/.nix-profile/etc/profile.d/hm-session-vars.sh`, and expects the shell's own config to source that script. `/home/chris/dotfiles/zshrc` is shared with the host and doesn't source it, so the work shell sources it before starting zsh.

The session variables are:

- `PATH` gains `/home/chris/dotfiles/bin` and `/home/chris/claude-instructions/scripts`, from `home.sessionPath`.
- `LIBSQLITE`, the nixpkgs `libsqlite3.so`, for nvim's sqlite.lua. Without it, sqlite.lua looks under the hidden `/usr/lib64`.

## Change the setup

| File | Holds |
|---|---|
| `/home/chris/dotfiles/flake.nix` | the inputs (nixpkgs-unstable, home-manager), and `layout`: the username, the homes and `hostPaths` |
| `/home/chris/dotfiles/nix/home.nix` | the home: packages, links, session variables, the `xdg-open` shim |
| `/home/chris/dotfiles/nix/packages.txt` | the package list |
| `/home/chris/dotfiles/nix/work-shell.nix` | the sandbox |
| `/home/chris/dotfiles/nix/pkg.nix` | the `pkg` command |

| To change | Edit |
|---|---|
| a package | `/home/chris/dotfiles/nix/packages.txt` |
| a dotfile link | the link set in `/home/chris/dotfiles/nix/home.nix` |
| a host path visible inside | `layout.hostPaths` in `/home/chris/dotfiles/flake.nix` |
| a session variable | `home.sessionVariables` in `/home/chris/dotfiles/nix/home.nix` |
| a directory on PATH | `home.sessionPath` in `/home/chris/dotfiles/nix/home.nix` |
| a library for prebuilt binaries | `nixLdLibraries` in `/home/chris/dotfiles/nix/work-shell.nix` |
| a variable passed in from the host | `inheritedEnv` in `/home/chris/dotfiles/nix/work-shell.nix` |

When each change takes effect:

| Change | Takes effect |
|---|---|
| packages | in open work shells, as soon as the switch finishes |
| dotfile edits | immediately, without a switch |
| session variables | in a new work shell |
| `/home/chris/dotfiles/nix/work-shell.nix`, `hostPaths` | in a new work shell, since the binds are set when it starts |

The flake sees only files git tracks. `git add` a new file under `/home/chris/dotfiles/nix` before you build, or the build won't find it.

These must stay true:

- Every host path visible inside is at the same path inside and outside. Paths cross the boundary through Docker, `xdg-open` and logs.
- `hostPaths` is the one list behind both the binds and the links.
- The dotfiles are shared with the host's dotbot setup, so `/home/chris/dotfiles/zshrc` and `/home/chris/dotfiles/gitconfig` have to work in both places. Call tools by name, so PATH finds them on either side.
- Bubblewrap has to keep working nested inside the work shell, because the Claude Code command server sandboxes every command with it. A flag that blocks new user namespaces inside, such as `--disable-userns` or a seccomp filter, breaks it.

To test a change without switching:

```sh
nix build /home/chris/dotfiles#homeConfigurations.chris.activationPackage   # builds the home
nix run /home/chris/dotfiles#work-shell -- -f -c '<command>'                # runs the new work shell, uninstalled
```

To apply it from outside the work shell, which is how a Claude session on the host does it:

```sh
/home/user/.nix-profile/bin/work-shell -f -c 'home-manager switch --flake /home/chris/dotfiles'
```

`pkg` needs an interactive fzf, so a Claude session edits `/home/chris/dotfiles/nix/packages.txt` and switches instead.
