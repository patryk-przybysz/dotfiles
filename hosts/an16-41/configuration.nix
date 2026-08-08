{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/limine
  ];

  my.nixos.limine.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "an16-41";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Warsaw";

  i18n = {
    defaultLocale = "pl_PL.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pl_PL.UTF-8";
      LC_IDENTIFICATION = "pl_PL.UTF-8";
      LC_MEASUREMENT = "pl_PL.UTF-8";
      LC_MONETARY = "pl_PL.UTF-8";
      LC_NAME = "pl_PL.UTF-8";
      LC_NUMERIC = "pl_PL.UTF-8";
      LC_PAPER = "pl_PL.UTF-8";
      LC_TELEPHONE = "pl_PL.UTF-8";
      LC_TIME = "pl_PL.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;
      xkb.layout = "pl";
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true; # kept as fallback session; pick niri at the SDDM session menu
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  programs.niri.enable = true;

  # Compx 2.4G wireless mouse: libinput can't detect its real DPI and assumes
  # 800, making everything ~2.5x too fast at the hardware's 2000 DPI.
  services.udev.extraHwdb = ''
    mouse:usb:v25a7pfa70:name:*:
     MOUSE_DPI=2000@125
    mouse:usb:v24aep1411:name:*:
     MOUSE_DPI=2000@125
  '';

  console.keyMap = "pl2";

  security.rtkit.enable = true;

  users.users.patryk = {
    isNormalUser = true;
    description = "Patryk Przybysz";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
