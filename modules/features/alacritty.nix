{
  features.alacritty.homeManager = {
    programs.alacritty = {
      enable = true;
      settings = {
        font.normal.family = "CommitMono Nerd Font";
      };
    };

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "Alacritty.desktop" ];
    };
  };
}
