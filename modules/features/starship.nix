{
  features.starship.homeManager = {
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
