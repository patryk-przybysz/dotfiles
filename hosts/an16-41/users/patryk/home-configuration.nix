{ inputs, ... }:
{
  imports = builtins.attrValues inputs.self.homeModules;

  my.home = {
    cli.enable = true;
    direnv.enable = true;
    fish.enable = true;
    fonts.enable = true;
    gh.enable = true;
    git.enable = true;
    jujutsu.enable = true;
    neovim.enable = true;
    nix-tools = {
      enable = true;
      osHost = "an16-41";
    };
    starship.enable = true;
    gaming.enable = true;
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

  programs.microsoft-edge = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
    ];
  };

  home.stateVersion = "26.05";
  home.language.base = "en_US.UTF-8";
}
