{
  pkgs,
  ...
}:
let
  catppuccinSddm = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
  };
in
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
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;
      xkb.layout = "pl";
    };
    displayManager = {
      defaultSession = "niri";
      sddm = {
        enable = true;
        theme = "${catppuccinSddm}/share/sddm/themes/catppuccin-mocha-mauve";
      };
    };
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
