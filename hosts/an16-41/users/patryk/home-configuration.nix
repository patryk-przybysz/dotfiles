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
    nix-tools.enable = true;
    starship.enable = true;
    js.enable = true;
    vesktop.enable = true;
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
}
