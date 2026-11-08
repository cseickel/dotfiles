# Declares the terminal environment: a home-manager config for the test home
# and the bubblewrap work shell that runs it.
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-index-database, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      layout = {
        username = "chris";
        home = "/home/user";
        hostHome = "/home/chris";
        # Directories under hostHome that the home links to. The work shell
        # creates any that are missing and binds them in at the same path, so
        # the links resolve on both sides.
        hostPaths = [
          "dotfiles"
          "repos"
          "claude-instructions"
          "Documents"
          "Downloads"
          "Pictures"
          ".ssh"
          ".doppler"
          ".claude"
          ".local/share/claude"
          ".local/rva-3-task-monitoring"
        ];
      };
    in
    {
      homeConfigurations.${layout.username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./nix/home.nix ];
        extraSpecialArgs = {
          inherit layout nixpkgs;
          homeManager = home-manager.packages.${system}.home-manager;
          nixIndex = nix-index-database.packages.${system}.nix-index-with-db;
        };
      };

      packages.${system}.work-shell = pkgs.callPackage ./nix/work-shell.nix { inherit layout; };
    };
}
