{
  description = "A nix flake-based development environment for Node.js with pnpm";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      nodeVersion = "24";
      pnpmVersion = "10";

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          }
        );

    in
    {
      overlays.default = final: prev: {
        pnpm = final."pnpm_${pnpmVersion}";
        nodejs = final."nodejs_${nodeVersion}";

      };

      devShells = forEachSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              pnpm
              nodejs
            ];
          };
        }
      );
    };
}
