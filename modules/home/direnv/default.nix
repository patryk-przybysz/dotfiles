{
  config,
  lib,
  ...
}:
let
  cfg = config.my.home.direnv;
in
{
  options.my.home.direnv.enable = lib.mkEnableOption "direnv with nix-direnv";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = false;
      nix-direnv.enable = true;
    };
  };
}
