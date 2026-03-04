{
  description = "A nix flake-based development environment for Go";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      goVersion = "25";

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
        go = final."go_1_${goVersion}";
      };

      devShells = forEachSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              go
              gopls # Language server
              gotools # official go tools
              go-tools # https://staticcheck.dev/
              golangci-lint # Linters runner

              impl # Generate method stubs for implementing an interface
              gotests # Generate Go tests
              delve # debugger
            ];
          };
        }
      );
    };
}
