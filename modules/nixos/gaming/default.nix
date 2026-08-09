{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nixos.gaming;
in
{
  options.my.nixos.gaming.enable = lib.mkEnableOption "gaming (Steam, gamemode, NTFS support)";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = true;

    # 32-bit graphics for older Proton titles (steam.enable pulls this in too)
    hardware.graphics.enable32Bit = true;

    # Let Steam see GE-Proton builds installed by protonup
    environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = [
      "/home/patryk/.steam/root/compatibilitytools.d"
    ];

    # NOTE: ntfs3g must not be installed here — its mount.ntfs helper shadows
    # the in-kernel ntfs driver (kernel 7.1+) for `ntfs` fstab entries.
    environment.systemPackages = with pkgs; [
      mangohud
      protonup-ng
    ];
  };
}
