{
  description = "Jay's collection of nix dev flake templates";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    {

      templates = {
        go = {
          path = ./go;
          description = "Golang development.";
        };

        node = {
          path = ./node;
          description = "Node development.";
        };

        buildroot = {
          path = ./buildroot;
          description = "buildroot development.";
        };
      };

    };
}
