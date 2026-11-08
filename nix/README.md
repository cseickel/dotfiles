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

The command exits back to the host shell when activation finishes. Then enter the work shell. The prompt shows `⬡ work` while you're inside:

```sh
/home/user/.nix-profile/bin/work-shell
```

Inside it, log in to GitHub once. The GitHub credential helper in `/home/chris/dotfiles/gitconfig` calls `gh`, and `gh` keeps its login in `/home/user/.config/gh`, which starts empty:

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

1. It searches the nixpkgs version locked in `/home/chris/dotfiles/flake.lock`, which is the same package set a switch installs. A term matches a package's name, its description, or a command it installs, so `pkg uuidgen` finds `util-linux.bin`.
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
| Claude Code's global config differs inside | `/home/chris/.claude` is shared, but `/home/user/.claude.json` is a separate file from `/home/chris/.claude.json`. It isn't linked, because Claude Code rewrites it and might replace a link with a plain file. | Check whether Claude Code keeps a symlinked `.claude.json` intact. If it does, link it in `/home/chris/dotfiles/nix/home.nix` and bind it in `/home/chris/dotfiles/nix/work-shell.nix`, because `hostPaths` holds only directories. |
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

```
host
 ├─ /home/chris ── hostPaths (dotfiles, repos, .ssh, ...) ──┐
 │                                                          │ bound in at the same paths
 └─ work-shell (bubblewrap)                                 │
     ├─ home: /home/user, built by home-manager  ◄──────────┘ and linked from the home
     ├─ tools: only what packages.txt declares, with the host's /usr hidden
     └─ host services: Docker, Wayland, D-Bus, the systemd user manager
```

Every host path that's visible inside sits at the same path on both sides. Paths cross the boundary whenever Docker mounts a directory or `xdg-open` hands a file to a desktop app, and the host resolves them in its own filesystem.

Host programs can't run inside. Prebuilt binaries that installers and nvim plugins download still run, through nix-ld, the same loader NixOS uses.

The sandbox keeps undeclared tools out. It doesn't stop a process inside from acting on the host, because the Docker socket and the systemd user manager are both reachable.

The details are in `/home/chris/dotfiles/nix/work-shell.nix` and `/home/chris/dotfiles/nix/home.nix`.

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
| a host directory visible inside | `layout.hostPaths` in `/home/chris/dotfiles/flake.nix` |
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
