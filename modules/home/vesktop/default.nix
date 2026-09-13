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
          ClearURLs.enabled = true;
          FixYoutubeEmbeds.enabled = true;
          ShowHiddenChannels.enabled = true;
          VolumeBooster.enabled = true;
          WebScreenShareFixes.enabled = true;
        };
      };
    };
  };
}
