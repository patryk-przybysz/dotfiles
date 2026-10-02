{
  features.direnv.homeManager = {
    programs.direnv = {
      enable = true;
      enableBashIntegration = false;
      nix-direnv.enable = true;
    };
  };
}
