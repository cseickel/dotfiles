# Declares the terminal environment: a home-manager config for the test home
# and the bubblewrap work shell that runs it.
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      layout = {
        username = "chris";
        home = "/home/user";
        hostHome = "/home/chris";
        # Paths under hostHome that the home links to, and that the work shell
        # binds in at the same path so the links resolve on both sides.
        hostPaths = [
          "dotfiles"
          "repos"
          "claude-instructions"
          "Documents"
          "Downloads"
          "Pictures"
          ".ssh"
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
        };
      };

      packages.${system}.work-shell = pkgs.callPackage ./nix/work-shell.nix { inherit layout; };
    };
}
