{
  config,
  lib,
  ...
}:
let
  cfg = config.my.home.gh;
in
{
  options.my.home.gh.enable = lib.mkEnableOption "GitHub CLI";

  config = lib.mkIf cfg.enable {
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
