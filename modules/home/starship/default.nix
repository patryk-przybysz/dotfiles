{
  config,
  lib,
  ...
}:
let
  cfg = config.my.home.starship;
in
{
  options.my.home.starship.enable = lib.mkEnableOption "starship prompt";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = false;
      presets = [ "nerd-font-symbols" ];
      settings = {
        nix_shell.heuristic = true;
      };
    };
  };
}
