{ inputs, pkgs, ... }:
{
  imports = builtins.attrValues inputs.self.homeModules;

  my.home = {
    cli.enable = true;
    direnv.enable = true;
    fish.enable = true;
    fonts.enable = true;
    gh.enable = true;
    git.enable = true;
    herdr.enable = true;
    jujutsu.enable = true;
    neovim.enable = true;
    nix-tools = {
      enable = true;
      osHost = "an16-41";
      generationLabels.enable = true;
    };
    starship.enable = true;
    gaming.enable = true;
    mcsr.enable = true;
    mpv.enable = true;
    js.enable = true;
    vesktop.enable = true;
    niri.enable = true;
    noctalia.enable = true;
    thunar.enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "CommitMono Nerd Font";
    };
  };

  home = {
    packages = [ pkgs.spotify ];
    stateVersion = "26.05";
    language.base = "en_US.UTF-8";
  };

  programs.microsoft-edge = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
    ];
  };
}
