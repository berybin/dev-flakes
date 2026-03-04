{
  description = "A nix flake-based development environment for C++";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
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
            pkgs = import nixpkgs { inherit system; };
          }
        );

    in
    {

      devShells = forEachSystem (
        { pkgs }:
        {
          default =
            pkgs.mkShell.override
              {

                # Override stdenv in order to change compiler:
                # stdenv = pkgs.clangStdenv;
              }

              {
                packages =
                  with pkgs;
                  [
                    clang-tools
                    codespell
                    cppcheck
                    vcpkg
                    vcpkg-tool
                  ]
                  ++ (if stdenv.hostPlatform.system == "aarch64-darwin" then [ ] else [ gdb ]);
              };
        }
      );
    };
}
