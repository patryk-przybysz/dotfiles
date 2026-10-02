{
  features.alacritty = {
    # The context entry is only useful once Nautilus is installed, and the
    # nautilus feature is what turns on gvfs.
    nixos =
      { config, lib, ... }:
      {
        programs.nautilus-open-any-terminal = lib.mkIf config.services.gvfs.enable {
          enable = true;
          terminal = "alacritty";
        };
      };

    homeManager = {
      programs.alacritty = {
        enable = true;
        settings = {
          font.normal.family = "CommitMono Nerd Font";
        };
      };
    };
  };
}
