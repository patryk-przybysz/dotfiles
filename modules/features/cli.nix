{ inputs, ... }:
{
  flake-file.inputs.sem = {
    url = "github:Ataraxy-Labs/sem";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
      flake-utils.inputs.systems.follows = "systems";
    };
  };

  features.cli.homeManager =
    { pkgs, ... }:
    {
      programs = {
        fzf = {
          enable = true;
          enableFishIntegration = true;
          enableBashIntegration = false;
        };
        nix-your-shell.enable = true;
        zoxide = {
          enable = true;
          enableBashIntegration = false;
        };
        fd.enable = true;
        bat.enable = true;
        ripgrep.enable = true;
        htop.enable = true;
        jq.enable = true;
      };

      home.packages = with pkgs; [
        tree
        unzip
        zip
        curl
        wget
        fastfetch
        inputs.sem.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
