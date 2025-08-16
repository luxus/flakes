{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-maid.url = "github:viperML/nix-maid";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;
        # Note: nix-maid is a library/function flake, not a package flake
        # It can be used via nixosModules or as a function, but doesn't provide packages
        #
        # Future nix-maid implementation examples:
        # 1. As NixOS module: Add nix-maid.nixosModules.default to modules list
        #    Then configure per-user: users.users.username.maid = { packages = [...]; };
        # 2. As standalone package: packages.maid-config = inputs.nix-maid pkgs { config };
        #
        # Currently removed since we use home-manager for user-level configuration

        # Home-Manager Integration (Isolated and Replaceable):
        # - Added as separate flake input with nixpkgs follows for consistency
        # - User config isolated in hosts/vanessa/home.nix for easy replacement
        # - Uses useGlobalPkgs and useUserPackages for better integration
        # - Can be easily removed by:
        #   1. Remove home-manager input from flake.nix
        #   2. Remove home-manager module from nixosConfigurations modules
        #   3. Remove home-manager config from hosts/vanessa/configuration.nix
        #   4. Delete hosts/vanessa/home.nix
        #   5. Move user packages back to users.users.luxus.packages if needed

        # KDE Plasma Integration (Isolated and Replaceable):
        # - Added plasma-manager as separate flake input with proper follows
        # - KDE Plasma 6 enabled at system level with Wayland support
        # - User KDE config isolated in hosts/vanessa/home.nix via plasma-manager
        # - Can be easily removed by:
        #   1. Remove plasma-manager input from flake.nix
        #   2. Remove plasma-manager from sharedModules in configuration.nix
        #   3. Remove KDE system services from configuration.nix
        #   4. Remove programs.plasma config from home.nix
        #   5. Remove KDE packages from environment.systemPackages if needed

        # Stylix System Theming (Isolated and Replaceable):
        # - Added stylix as separate flake input with proper follows
        # - System-wide theming enabled with NixOS module
        # - Home-Manager integration via sharedModules for user applications
        # - Base16 color scheme generation from wallpaper or manual scheme
        # - Consistent font configuration across system and applications
        # - Can be easily removed by:
        #   1. Remove stylix input from flake.nix
        #   2. Remove stylix modules from nixosConfigurations and sharedModules
        #   3. Remove stylix config from configuration.nix
        #   4. Remove any stylix-specific config from home.nix if added
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

        nixosConfigurations = {
          vanessa = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs;
            };
            modules = [
              inputs.nixos-facter-modules.nixosModules.facter
              { config.facter.reportPath = ./hosts/vanessa/facter.json; }
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.sharedModules = [
                  inputs.plasma-manager.homeManagerModules.plasma-manager
                  inputs.stylix.homeModules.stylix
                ];
              }
              inputs.stylix.nixosModules.stylix
              ./hosts/vanessa/configuration.nix
              inputs.disko.nixosModules.disko
            ];
          };
        };
      };
    };
}
