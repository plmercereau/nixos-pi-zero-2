{
  description = "Flake for building a Raspberry Pi Zero 2 SD image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        crossPkgs = import "${nixpkgs}" {
          localSystem = system;
          crossSystem = "aarch64-linux";
        };
      in
      rec {
        nixosConfigurations = {
          zero2w = nixpkgs.lib.nixosSystem {
            modules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./zero2w.nix
              {
                nixpkgs.pkgs = crossPkgs; # configure cross compilation. If the build system `system` is aarch64, this will provide the aarch64 nixpkgs
              }
            ];
          };
        };

        deploy = {
          user = "root";
          nodes = {
            zero2w = {
              hostname = "zero2w";
              profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.zero2w;
            };
          };
        };
      }
    )
    // {
      nixosModules.sd-image =
        { inputs, ... }:
        {
          imports = [
            "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./sd-image.nix
            ./sd-defaults.nix
          ];
        };

      nixosModules.hardware = ./hardware.nix;
    };
}
