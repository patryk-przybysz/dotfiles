# Div Acer Manager Max on NixOS (linuwu_sense + root daemon + Avalonia GUI).
#
# Patterns borrowed from:
# - https://github.com/Nailington/dots/tree/main/modules/nixos/damx
#   (force modprobe params, modules-load ordering, kmod in PATH, unload on shutdown)
# - https://gitlab.com/sbstratos79/nix-flakes/-/blob/main/modules/damx.nix
#   (installDrivers toggle, package overrides, keep the GUI bundle intact for Skia)
# - https://github.com/Hinn27/nixos-dotfiles/blob/main/nixos/damx.nix
#   (blacklist acer_wmi so linuwu_sense can bind)
#
# Upstream installer (setup.sh) writes /opt/damx and /etc/modprobe.d; that
# fights the Nix store on the next switch. Internals Manager "make parameter
# persistent" is the same — use `my.nixos.damx.force` / `extraModprobeConfig`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nixos.damx;
  src = pkgs.callPackage ./src.nix { };
  linuwu-sense = config.boot.kernelPackages.callPackage ./linuwu-sense.nix { inherit src; };
  damx-daemon = pkgs.callPackage ./daemon.nix { inherit src; };
  damx-gui = pkgs.callPackage ./gui.nix { inherit src; };

  forceParams = {
    nitro_v4 = "nitro_v4=1";
    predator_v4 = "predator_v4=1";
    enable_all = "enable_all=1";
  };
in
{
  options.my.nixos.damx = {
    enable = lib.mkEnableOption "Div Acer Manager Max (linuwu_sense, daemon, GUI)";

    installDrivers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Build and load the out-of-tree linuwu_sense kernel module.";
    };

    force = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "nitro_v4"
          "predator_v4"
          "enable_all"
        ]
      );
      default = null;
      description = ''
        Permanent linuwu_sense module parameter at load (same as DAMX Internals
        Manager force modes). Use if the GUI shows Unknown model after reboot
        even on a listed model — DMI matching is flaky on some Acer firmware.
      '';
    };

    extraModprobeConfig = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "enable_all=1";
      description = "Additional `options linuwu_sense …` parameters.";
    };

    guiPackage = lib.mkOption {
      type = lib.types.package;
      default = damx-gui;
      defaultText = lib.literalExpression "pkgs.callPackage ./gui.nix { }";
      description = "DAMX GUI package.";
    };

    daemonPackage = lib.mkOption {
      type = lib.types.package;
      default = damx-daemon;
      defaultText = lib.literalExpression "pkgs.callPackage ./daemon.nix { }";
      description = "DAMX daemon package.";
    };

    linuwuSensePackage = lib.mkOption {
      type = lib.types.package;
      default = linuwu-sense;
      defaultText = lib.literalExpression "config.boot.kernelPackages.callPackage ./linuwu-sense.nix { }";
      description = "linuwu_sense kernel module package.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      extraModulePackages = lib.mkIf cfg.installDrivers [ cfg.linuwuSensePackage ];
      kernelModules = lib.mkIf cfg.installDrivers [ "linuwu_sense" ];
      blacklistedKernelModules = lib.mkIf cfg.installDrivers [ "acer_wmi" ];
      extraModprobeConfig = lib.mkIf (cfg.force != null || cfg.extraModprobeConfig != "") ''
        options linuwu_sense ${
          lib.concatStringsSep " " (
            lib.optional (cfg.force != null) forceParams.${cfg.force}
            ++ lib.optional (cfg.extraModprobeConfig != "") cfg.extraModprobeConfig
          )
        }
      '';
    };

    # Nitro/Predator Sense key: EC scancode 0xf5 (often keycode 425). Map to
    # XF86Launch1 so niri can bind it without DAMX's evtest helper service.
    services.udev.extraHwdb = ''
      evdev:atkbd:dmi:bvn*:bvr*:bd*:svnAcer*:pn*:pvr*
       KEYBOARD_KEY_f5=prog1
    '';

    systemd.services.damx-daemon = {
      description = "DAMX Daemon for Acer laptops";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      wants = [ "systemd-modules-load.service" ];
      path = [
        pkgs.kmod
        pkgs.sudo
        pkgs.coreutils
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.daemonPackage}/bin/DAMX-Daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Upstream Linuwu-Sense ships a oneshot that rmmod's on shutdown.
    systemd.services.linuwu-sense-unload = lib.mkIf cfg.installDrivers {
      description = "Unload linuwu_sense at shutdown";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${pkgs.kmod}/bin/rmmod linuwu_sense";
      };
    };

    environment.systemPackages = [
      cfg.guiPackage
      cfg.daemonPackage
    ];
  };
}
