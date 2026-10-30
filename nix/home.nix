# Declares the packages and links that make up the home at layout.home.
{ config, lib, pkgs, layout, nixpkgs, homeManager, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${layout.hostHome}/dotfiles";
  packageNames = lib.filter (name: name != "") (lib.splitString "\n" (builtins.readFile ./packages.txt));

  # The sandbox can't run host binaries, so this asks the host's systemd user
  # manager to run the host's gio, which honors Terminal=true under niri where
  # xdg-utils doesn't.
  xdgOpen = pkgs.writeShellScriptBin "xdg-open" ''
    exec ${pkgs.systemd}/bin/systemd-run --user --quiet --collect --same-dir -- gio open "$@"
  '';
in
{
  home.username = layout.username;
  home.homeDirectory = layout.home;
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.sessionPath = [
    "${dotfiles}/bin"
    "${layout.hostHome}/claude-instructions/scripts"
  ];

  home.sessionVariables = {
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
  };

  home.packages =
    map (name: lib.getAttrFromPath (lib.splitString "." name) pkgs) packageNames
    ++ [
      (pkgs.callPackage ./work-shell.nix { inherit layout; })
      (pkgs.callPackage ./pkg.nix { inherit homeManager nixpkgs dotfiles; })
      xdgOpen
    ];

  home.file =
    lib.genAttrs layout.hostPaths (path: { source = link "${layout.hostHome}/${path}"; })
    // lib.mapAttrs (_: file: { source = link "${dotfiles}/${file}"; }) {
      ".gitconfig" = "gitconfig";
      ".visidatarc" = "visidatarc";
      ".zshenv" = "zshenv";
      ".zshrc" = "zshrc";
      ".config/nvim" = "config/nvim";
      ".config/starship.toml" = "config/starship.toml";
    }
    // {
      ".oh-my-zsh".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
      # $EDITOR in the zshrc. The zshrc writes a host version that opens kitty
      # unless this file already exists.
      ".local/bin/edit.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          exec nvim "$@"
        '';
      };
    };
}
