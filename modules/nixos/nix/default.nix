{
  config,
  lib,
  ...
}:
let
  cfg = config.my.nixos.nix;
in
{
  options.my.nixos.nix.enable =
    lib.mkEnableOption "shared Nix daemon settings (GC, optimisation, substituters)";

  config = lib.mkIf cfg.enable {
    nix = {
      optimise.automatic = true;

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      settings = {
        auto-optimise-store = true;

        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Add to the default cache.nixos.org; do not replace it.
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://devenv.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dRUhiXd/UhA17imdUmoYqt/5xVIXI0O+w="
          "devenv.cachix.org-1:w1c0WM8sbBS/+2QQVKqHsBrun/NoCVH2EHnumwgLc4I="
        ];
      };
    };
  };
}
