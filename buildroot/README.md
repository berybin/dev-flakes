# Buildroot development shell

This flake was based on the dependencies / packages mentioned [here](https://buildroot.org/downloads/manual/manual.html#requirement-mandatory).
At the time of creation, the buildroot version was 2025.02.4.

## Using this flake
Run `nix develop` to expose the necessary tools to your shell.

To get started, we need to download and extract buildroot:

```bash
# Download and extract buildroot
wget http://buildroot.org/downloads/buildroot-2025.02.4.tar.gz
tar xzvf buildroot-2025.02.4.tar.gz
cd buildroot-2025.02.4

# Generate default config
make qemu_aarch64_virt_defconfig

# Build all
make
```
