{
  features.vesktop.homeManager = {
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
