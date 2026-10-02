{
  features.fonts.homeManager =
    { pkgs, ... }:
    {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs; [
        nerd-fonts.commit-mono
        libertine
        font-awesome
        corefonts
        vista-fonts
      ];
    };
}
