{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.dendritic ];

  flake-file = {
    description = "Home Manager configuration of patryk";

    inputs = {
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:vic/import-tree";
    };
  };
}
