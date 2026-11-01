# Searches the flake's locked nixpkgs by name, description and installed
# command, lets you pick matches in fzf, adds them to packages.txt, and switches
# the home to install them.
{
  writeShellApplication,
  coreutils,
  util-linux,
  gnused,
  gawk,
  jq,
  fzf,
  nix,
  homeManager,
  nixIndex,
  nixpkgs,
  dotfiles,
}:
writeShellApplication {
  name = "pkg";
  runtimeInputs = [ coreutils util-linux gnused gawk jq fzf nix homeManager nixIndex ];
  text = ''
    if (( $# == 0 )); then
      echo "usage: pkg <search terms>" >&2
      exit 2
    fi

    packages_file=${dotfiles}/nix/packages.txt

    # nix-locate names each package by attribute and output, such as
    # util-linux.bin. The out output is the package itself.
    command_matches=$(
      for term in "$@"; do
        nix-locate --minimal --whole-name --at-root "/bin/$term" |
          sed -e 's/\.out$//' -e "s|\$|\t-\tinstalls the $term command|"
      done
    )
    search_matches=$(
      nix search "path:${nixpkgs}" "$@" --json |
        jq -r 'to_entries[]
          | [(.key | sub("^legacyPackages\\.[^.]+\\."; "")), .value.version, .value.description]
          | @tsv'
    )
    matches=$(
      printf '%s\n%s\n' "$command_matches" "$search_matches" |
        awk -F '\t' 'NF && !seen[$1]++'
    )
    if [[ -z $matches ]]; then
      echo "pkg: no packages match: $*" >&2
      exit 1
    fi

    chosen=$(
      column -t -s $'\t' <<<"$matches" |
        fzf --multi --no-hscroll --header "Tab selects, Enter installs" |
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
