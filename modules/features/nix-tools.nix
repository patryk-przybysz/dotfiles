{
  features.nix-tools.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.home.nix-tools;

      flakePath = if cfg.flake != null then cfg.flake else "${config.home.homeDirectory}/dotfiles";
    in
    {
      options.my.home.nix-tools.flake = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/home/patryk/dotfiles";
        description = ''
          Path to the dotfiles flake root. Sets {env}`NH_FLAKE`.
          Defaults to {file}`$HOME/dotfiles`.
          {command}`nh os` appends the live hostname, which must match
          {code}`nixosConfigurations.<hostname>`.
        '';
      };

      config = {
        programs.nh = {
          enable = true;
          flake = flakePath;
          clean = {
            enable = true;
            dates = "weekly";
            extraArgs = "--keep 10 --keep-since 14d";
          };
        };

        programs.fish = lib.mkIf config.programs.fish.enable {
          shellAbbrs = {
            os = "nh os switch";
            osl = "nh os switch --show-activation-logs";
            ost = "nh os test";
            ncl = "nh clean all";
            gens = "nixos-rebuild list-generations";
          }
          # Inside NixOS, home-manager is applied by `nh os switch`.
          // lib.optionalAttrs (!config.submoduleSupport.enable) {
            hm = "nh home switch";
          };
        };

        home.packages = [
          pkgs.nil
          pkgs.nixfmt
          pkgs.devenv
        ];
      };
    };
}
