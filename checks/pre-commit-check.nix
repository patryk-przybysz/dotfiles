{
  inputs,
  pkgs,
  system,
  ...
}:
let
  treefmtEval = inputs.treefmt.lib.evalModule pkgs ../treefmt.nix;
in
inputs.git-hooks.lib.${system}.run {
  src = inputs.self;
  hooks = {
    nil.enable = true;
    statix = {
      enable = true;
      excludes = [ "hardware-configuration\\.nix$" ];
    };
    treefmt = {
      enable = true;
      package = treefmtEval.config.build.wrapper;
    };
  };
}
