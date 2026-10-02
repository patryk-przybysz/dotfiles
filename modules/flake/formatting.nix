{ inputs, ... }:
{
  imports = [ inputs.treefmt.flakeModule ];

  flake-file.inputs.treefmt = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    programs.nixfmt.enable = true;
    programs.stylua.enable = true;
  };
}
