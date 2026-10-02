{
  features.gaming = {
    nixos =
      { pkgs, ... }:
      {
        programs.steam = {
          enable = true;
          gamescopeSession.enable = true;
        };
        programs.gamemode.enable = true;

        # 32-bit graphics for older Proton titles (steam.enable pulls this in too)
        hardware.graphics.enable32Bit = true;

        # NOTE: ntfs3g must not be installed here — its mount.ntfs helper shadows
        # the in-kernel ntfs driver (kernel 7.1+) for `ntfs` fstab entries.
        environment.systemPackages = with pkgs; [
          mangohud
          protonup-ng
        ];
      };

    # protonup installs GE-Proton into that user's Steam directory.
    homeManager =
      { config, pkgs, ... }:
      {
        home.packages = [ pkgs.faugus-launcher ];
        home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${config.home.homeDirectory}/.steam/root/compatibilitytools.d";
      };
  };
}
