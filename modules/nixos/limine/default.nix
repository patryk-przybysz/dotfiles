{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nixos.limine;

  tokyoNightLimine = pkgs.fetchFromGitHub {
    owner = "Bukutsu";
    repo = "tokyo-night-limine";
    rev = "a2e9b61b2b1b815bf0173bf5f910c9c213014b33";
    hash = "sha256-gVr5ukL+HeOxwTNT6kmGbVCDuJ94+mI8qbH2LnC/5Ms=";
  };
in
{
  options.my.nixos.limine = {
    enable = lib.mkEnableOption "Limine bootloader with Tokyo Night theme";

    maxGenerations = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Maximum number of NixOS generations shown in the boot menu.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.loader.limine = {
      enable = true;
      enableEditor = false;
      inherit (cfg) maxGenerations;
      extraConfig = builtins.readFile "${tokyoNightLimine}/tokyo-night.conf";
      extraEntries = ''
        /Windows Boot Manager
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';
      style.wallpapers = [ ];
    };
  };
}
