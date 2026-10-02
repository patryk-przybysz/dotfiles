{
  config,
  lib,
  ...
}:
let
  cfg = config.my.home.git;
in
{
  options.my.home.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user = {
          name = "Patryk Przybysz";
          email = "pprzybysz04@outlook.com";
          github = "patryk-przybysz";
        };
      };
    };
  };
}
