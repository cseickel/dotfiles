# Runs zsh in a bubblewrap sandbox whose home is layout.home, with the host's
# /usr hidden, only layout.hostPaths visible from the host home, and nix-ld as
# the loader for prebuilt binaries.
{
  lib,
  writeShellApplication,
  writeShellScript,
  writeText,
  bubblewrap,
  coreutils,
  bash,
  zsh,
  nix,
  cacert,
  tzdata,
  glibcLocales,
  nix-ld,
  stdenv,
  zlib,
  zstd,
  curl,
  openssl,
  attr,
  libssh,
  bzip2,
  libxml2,
  acl,
  libsodium,
  util-linux,
  xz,
  systemd,
  layout,
}:
let
  locales = glibcLocales.override {
    allLocales = false;
    locales = [ "en_US.UTF-8/UTF-8" ];
  };
  nsswitch = writeText "nsswitch.conf" ''
    passwd: files
    group: files
    hosts: files dns
  '';
  certs = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  # Libraries that prebuilt binaries commonly link, the same set NixOS gives
  # nix-ld by default.
  nixLdLibraries = [
    stdenv.cc.cc
    zlib
    zstd
    curl
    openssl
    attr
    libssh
    bzip2
    libxml2
    acl
    libsodium
    util-linux
    xz
    systemd
  ];
  # The zshrc is a plain dotfile that never sources home-manager's session
  # variables, so they are sourced here before zsh starts.
  init = writeShellScript "work-shell-init" ''
    session_vars="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    if [ -f "$session_vars" ]; then
      . "$session_vars"
    fi
    exec ${zsh}/bin/zsh "$@"
  '';
  hostPaths = map (path: "${layout.hostHome}/${path}") layout.hostPaths;
  inheritedEnv = [
    "TERM"
    "COLORTERM"
    "TERM_PROGRAM"
    "TERM_PROGRAM_VERSION"
    "LANG"
    "WAYLAND_DISPLAY"
    "DISPLAY"
    "XDG_RUNTIME_DIR"
    "XDG_SESSION_TYPE"
    "XDG_CURRENT_DESKTOP"
    "DBUS_SESSION_BUS_ADDRESS"
    "SSH_AUTH_SOCK"
  ];
in
writeShellApplication {
  name = "work-shell";
  runtimeInputs = [ bubblewrap coreutils ];
  text = ''
    home=${lib.escapeShellArg layout.home}
    shell=${zsh}/bin/zsh
    user=$(id -un)

    args=(
      --ro-bind /nix /nix
      --bind "$home" "$home"
      --bind /tmp /tmp
      --bind /var/tmp /var/tmp
      --symlink ../run /var/run
      --dev-bind /dev /dev
      --proc /proc
      --ro-bind /sys /sys
      --ro-bind ${nsswitch} /etc/nsswitch.conf
      --dir /etc/ssl/certs
      --symlink ${certs} /etc/ssl/certs/ca-certificates.crt
      --dir /bin
      --symlink ${bash}/bin/sh /bin/sh
      --dir /usr/bin
      --symlink ${coreutils}/bin/env /usr/bin/env
      --dir /lib64
      --symlink ${nix-ld}/libexec/nix-ld /lib64/ld-linux-x86-64.so.2
      --clearenv
      --setenv HOME "$home"
      --setenv USER "$user"
      --setenv LOGNAME "$user"
      --setenv SHELL "$shell"
      --setenv PATH "$home/.nix-profile/bin:${nix}/bin"
      --setenv TERMINFO_DIRS "$home/.nix-profile/share/terminfo"
      --setenv LOCALE_ARCHIVE ${locales}/lib/locale/locale-archive
      --setenv TZDIR ${tzdata}/share/zoneinfo
      --setenv SSL_CERT_FILE ${certs}
      --setenv NIX_SSL_CERT_FILE ${certs}
      --setenv NIX_LD ${stdenv.cc.bintools.dynamicLinker}
      --setenv NIX_LD_LIBRARY_PATH ${lib.makeLibraryPath nixLdLibraries}
      --setenv WORK_SHELL 1
    )

    bind_if_exists() {
      if [[ -e $2 ]]; then
        args+=("$1" "$2" "''${3:-$2}")
      fi
    }
    bind_if_exists --ro-bind /etc/nix
    bind_if_exists --ro-bind /etc/passwd
    bind_if_exists --ro-bind /etc/group
    bind_if_exists --ro-bind /etc/hosts
    bind_if_exists --ro-bind /etc/machine-id
    bind_if_exists --ro-bind "$(realpath /etc/resolv.conf)" /etc/resolv.conf
    bind_if_exists --bind "/run/user/$(id -u)"
    bind_if_exists --bind /run/docker.sock

    cwd=$home
    if [[ $PWD == "$home" || $PWD == "$home"/* ]]; then
      cwd=$PWD
    fi
    for path in ${lib.escapeShellArgs hostPaths}; do
      bind_if_exists --bind "$path"
      if [[ $PWD == "$path" || $PWD == "$path"/* ]]; then
        cwd=$PWD
      fi
    done

    if [[ -L /etc/localtime ]]; then
      zone=$(readlink /etc/localtime)
      args+=(--setenv TZ "''${zone#*zoneinfo/}")
    fi

    for name in ${lib.escapeShellArgs inheritedEnv}; do
      if [[ -v $name ]]; then
        args+=(--setenv "$name" "''${!name}")
      fi
    done

    exec bwrap "''${args[@]}" --chdir "$cwd" -- ${init} "$@"
  '';
}
