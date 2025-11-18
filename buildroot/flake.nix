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
        let
          # we need to use pkgs.buildFHSEnv as find expects to be at /usr/bin/find as per https://buildroot.org/downloads/manual/manual.html#requirement-mandatory
          buildrootFHSEnv =
            (pkgs.buildFHSEnv {
              name = "buildroot";
              targetPkgs =
                pkgs:
                (
                  with pkgs;
                  [
                    pkg-config

                    # NOTE: change this to your target platform. Not actually sure this is needed.
                    pkgsCross.aarch64-multiplatform.gccStdenv.cc
                    # pkgsCross.raspberryPi.gccStdenv.cc

                    # NOTE: this is needed for c lib crypt stuff.
                    # glibc doesn't provide crpyt functionality in NixOS, it has to be specifically added by libxcrpyt.
                    # libxcrpyt had build errors, but the libxcrypt-legacy version actually produced an image
                    libxcrypt-legacy

                    which
                    gnused
                    gnumake
                    binutils
                    diffutils
                    (lib.hiPrio gcc)
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

                    # asciidoc
                    # w3m
                  ]
                  ++ pkgs.linux.nativeBuildInputs
                );
            }).env;
        in
        {
          default = buildrootFHSEnv.overrideAttrs (oldAttrs: {
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
              pkgs.wget
              pkgs.gnupg
              pkgs.coreutils
              pkgs.gnugrep
              pkgs.gawk
            ];

            shellHook = ''
              set -e

              BUILDROOT_DIR=br
              BUILDROOT_VERSION=2025.02.7

              TARBALL="buildroot-$BUILDROOT_VERSION.tar.gz"
              SIGNATURE="$TARBALL.sign"

              URL="https://buildroot.org/downloads/"
              TARBALL_URL="$URL$TARBALL"
              SIGNATURE_URL="$URL$SIGNATURE"
              PUBLIC_KEY_URL=https://gitlab.com/-/snippets/4836881/raw/main/arnout@rnout.be.asc


              if [ ! -d "$BUILDROOT_DIR" ]; then

                # tarball already exists from previous attempt, remove
                if [ -f "$TARBALL" ]; then
                  echo Removing old tarball...
                  rm $TARBALL*
                fi

                if [ -f "$SIGNATURE" ]; then
                  echo Removing old signature file...
                  rm $SIGNATURE*
                fi
                 

                echo "Fetching buildroot ($BUILDROOT_VERSION) tarball and signature..."
                wget -q --show-progress $TARBALL_URL $SIGNATURE_URL
                echo

                echo Fetching GPG key to verify signature...
                curl -s $PUBLIC_KEY_URL | gpg -q --import

                echo Verifying signature of checksum file...
                gpg --quiet --verify $SIGNATURE 2> /dev/null

                echo Signature valid. Verifying tarball checksum...
                echo

                EXPECTED_HASH=$(grep 'SHA256' "$SIGNATURE" | awk '{print $2}')
                ACTUAL_HASH=$(sha256sum $TARBALL | awk '{print $1}')

                echo "Expected SHA256: $EXPECTED_HASH"
                echo "Actual SHA256:   $ACTUAL_HASH"
                echo

                if [ $EXPECTED_HASH != $ACTUAL_HASH ]; then
                  echo Uh oh, checksum mismatch! The tarball is invalid...
                  exit 1
                fi

                echo Checksum okay, extracting now...
                echo

                tar -xzf "$TARBALL"
                mv "buildroot-$BUILDROOT_VERSION" "$BUILDROOT_DIR"

                rm -f "$TARBALL" "$SIGNATURE"

                echo Buildroot setup complete!
                echo "Buildroot can be found in ($BUILDROOT_DIR)"
                echo
              else
                echo "Buildroot directory ($BUILDROOT_DIR) already exists..."
              fi
            '';
          });
        }
      );
    };
}
