{
  description = "A nix flake-based development environment for buildroot";
  # this flake was heavily inspired by:
  # - https://discourse.nixos.org/t/buildroot-nix-shell/19369
  # - https://github.com/mayl/buildroot_flake

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
            pkgs = import nixpkgs {
              inherit system;
            };
          }
        );

    in
    {

      devShells = forEachSystem (
        { pkgs }:
        {
          default =
            # we need to use pkgs.buildFHSEnv as find expects to be at /usr/bin/find as per https://buildroot.org/downloads/manual/manual.html#requirement-mandatory
            (pkgs.buildFHSEnv {
              name = "buildroot";
              targetPkgs =
                pkgs: with pkgs; [
                  pkg-config
                  pkgsCross.aarch64-multiplatform.gccStdenv.cc

                  which
                  gnused
                  gnumake
                  binutils
                  diffutils
                  gcc
                  gnupatch
                  gzip
                  bzip2
                  perl
                  gnutar
                  cpio
                  unzip
                  rsync
                  file
                  bc
                  findutils
                  gawk
                  wget

                  # optional
                  python3Minimal
                  ncurses.dev

                  asciidoc
                  w3m
                ];
            }).env;
        }
      );
    };
}
