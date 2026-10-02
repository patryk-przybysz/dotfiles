{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  flake-file.inputs.git-hooks = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # treefmt's package comes from the formatting module.
  perSystem.pre-commit.settings.hooks = {
    nil.enable = true;
    statix = {
      enable = true;
      excludes = [ "hardware-configuration\\.nix$" ];
    };
    treefmt.enable = true;
  };
}
