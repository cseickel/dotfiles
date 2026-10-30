# Searches the flake's locked nixpkgs, lets you pick matches in fzf, adds them
# to packages.txt, and switches the home to install them.
{
  writeShellApplication,
  coreutils,
  util-linux,
  jq,
  fzf,
  nix,
  homeManager,
  nixpkgs,
  dotfiles,
}:
writeShellApplication {
  name = "pkg";
  runtimeInputs = [ coreutils util-linux jq fzf nix homeManager ];
  text = ''
    if (( $# == 0 )); then
      echo "usage: pkg <search terms>" >&2
      exit 2
    fi

    packages_file=${dotfiles}/nix/packages.txt

    matches=$(
      nix search "path:${nixpkgs}" "$@" --json |
        jq -r 'to_entries[]
          | [(.key | sub("^legacyPackages\\.[^.]+\\."; "")), .value.version, .value.description]
          | @tsv'
    )
    if [[ -z $matches ]]; then
      echo "pkg: no packages match: $*" >&2
      exit 1
    fi

    chosen=$(
      column -t -s $'\t' <<<"$matches" |
        fzf --multi --header "Tab selects, Enter installs" |
        cut -d ' ' -f 1
    ) || exit 0

    original=$(cat "$packages_file")
    sort -u -o "$packages_file" "$packages_file" - <<<"$chosen"

    if ! home-manager switch --flake ${dotfiles}; then
      printf '%s\n' "$original" >"$packages_file"
      echo "pkg: switch failed, so packages.txt is restored" >&2
      exit 1
    fi
  '';
}
