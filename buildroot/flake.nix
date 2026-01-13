{
  description = "A nix flake-based development environment for Buildroot";

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
            pkgs = import nixpkgs { inherit system; };
          }
        );

    in
    {

      devShells = forEachSystem (
        { pkgs }:
        let
          buildroot-fhs = pkgs.buildFHSEnv {
            name = "buildroot-fhs";

            targetPkgs = (
              pkgs:
              with pkgs;
              pkgs.linux.nativeBuildInputs
              ++ [
                pkg-config # unsure if required
                (lib.hiPrio gcc)

                bc
                binutils
                bzip2
                ccache
                cpio
                diffutils
                expat # not mentioned in buildroot deps; dep of host-libxml-parser-perl
                expect # not mentioned in buildroot deps
                file
                findutils
                gawk # awk
                # glib # not mentioned; not sure if necessary
                glibc # transitively mentioned: debian build-essential
                gnumake # make
                gnupatch # patch
                gnused # sed
                gnutar # tar
                gzip
                libxcrypt # not mentioned in buildroot deps; required for host-mkpasswd
                # libxcrypt-legacy # if libxcrypt has build issues, we may need the legacy version
                ncurses.dev
                perl
                rsync
                unzip
                wget
                which
              ]
            );
          };

        in
        {
          br = buildroot-fhs.env;
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              wget
            ];

            shellHook = ''
              echo "✅ Direnv loaded!"
              echo "👷🔨 Run 'nix develop .#br' to enter the Buildroot FHS environment."
            '';
          };
        }
      );
    };
}
