{
  config,
  lib,
  ...
}:
let
  cfg = config.my.home.vesktop;
in
{
  options.my.home.vesktop.enable = lib.mkEnableOption "Vesktop (Discord with Vencord)";

  config = lib.mkIf cfg.enable {
    programs.vesktop = {
      enable = true;

      vencord.settings = {
        plugins = {
          ClearURLs.enable = true;
          FixYoutubeEmbeds.enable = true;
        };
      };
    };
  };
}
