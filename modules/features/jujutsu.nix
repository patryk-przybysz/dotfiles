{
  config,
  lib,
  ...
}:
let
  cfg = config.my.home.jujutsu;
in
{
  options.my.home.jujutsu.enable = lib.mkEnableOption "jujutsu VCS";

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings.user = {
        inherit (config.programs.git.settings.user) name email;
      };
    };
  };
}
