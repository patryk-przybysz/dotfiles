{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.home.mcsr;
  mcsrPkgs = inputs.mcsr.packages.${pkgs.stdenv.hostPlatform.system};

  # https://tesselslate.github.io/waywall/01_ninb.html (NixOS blank Swing window)
  ninjabrain-bot = mcsrPkgs.ninjabrain-bot.override {
    extraJavaArgs = [
      "-Dawt.useSystemAAFontSettings=on"
      "-Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel"
    ];
  };
in
{
  imports = [ inputs.mcsr.homeManagerModules.waywall ];

  config = lib.mkIf cfg.enable {
    home.packages = [ ninjabrain-bot ];

    # Multi-file config: mcsr-nixos only ships init.lua (finalFile); siblings go here.
    # Store copies on purpose. DO NOT hot-reload by editing/cp into ~/.config/waywall
    # while Minecraft is running — waywall SIGSEGVs in config_vm_resume and MC dies
    # with exit 111 (ECONNREFUSED / compositor gone). Edit → nh home switch → relaunch.
    # Layout inspired by https://github.com/arjuncgore/waywall_generic_config
    home.file = {
      ".config/xkb/symbols/mc".source = ./xkb/mc;
      ".config/waywall/settings.lua".source = ./settings.lua;
      ".config/waywall/main.lua".source = ./main.lua;
      ".config/waywall/remaps.lua".source = ./remaps.lua;
      ".config/waywall/extras.lua".source = ./extras.lua;
    };

    programs.waywall = {
      enable = true;
      config = {
        # https://github.com/Esensats/waywork
        enableWaywork = true;
        programs = [
          ninjabrain-bot
          mcsrPkgs.paceman-tracker
        ];
        files = {
          eye_overlay = ./resources/eye_overlay.png;
        };
        source = ./init.lua;
      };
    };
  };
}
