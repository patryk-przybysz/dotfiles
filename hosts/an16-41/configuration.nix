{
  inputs,
  pkgs,
  config,
  ...
}:
let
  catppuccinSddm = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
  };
in
{
  imports = [ ./hardware-configuration.nix ] ++ builtins.attrValues inputs.self.nixosModules;

  my.nixos = {
    limine.enable = true;
    gaming.enable = true;
    nvidia.enable = true;
    # Dedicated RAM disk for RSG worlds — not boot.tmp.useTmpfs (/tmp).
    # https://its-saanvi.github.io/linux-mcsr/tmpfs.html
    # Pattern: https://github.com/flammablebunny/flake (hosts/pc tmpfs + cleanup)
    mcsr.tmpfs = {
      enable = true;
      size = "4G";
      keepWorlds = 1000;
      instances.RSG.savesPath = "/home/patryk/.local/share/PrismLauncher/instances/1.16.1 RSG/minecraft/saves";
    };
  };

  # Kernel 7.1 for the new in-kernel ntfs driver used below
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Shared Windows games library on the new in-kernel ntfs driver (7.1+).
  # nofail so a hibernation-locked drive can't block boot.
  fileSystems."/media/games" = {
    device = "/dev/disk/by-uuid/D0C0A2DCC0A2C854";
    fsType = "ntfs";
    options = [
      "uid=1000"
      "gid=100"
      "nofail"
      "rw"
      "exec"
      "umask=000"
    ];
  };

  # Proton prefixes must stay on a Linux fs. The in-kernel ntfs driver
  # doesn't expose NTFS symlinks as symlinks, so bind-mount instead.
  fileSystems."/media/games/SteamLibrary/steamapps/compatdata" = {
    device = "/home/patryk/.steam/steam/steamapps/compatdata-games";
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
  };

  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "an16-41";
    networkmanager.enable = true;
  };

  # Prefixes each generation label in the Limine boot menu (system.nixos.label).
  system.nixos.tags = [ config.networking.hostName ];

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
    upower.enable = true;
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

  home-manager.backupFileExtension = "hm-bak";

  # Compx 2.4G wireless mouse: libinput can't detect its real DPI and assumes
  # 800, making everything ~2.5x too fast at the hardware's 2000 DPI.
  services.udev.extraHwdb = ''
    mouse:usb:v25a7pfa70:name:*:
     MOUSE_DPI=2000@125
    mouse:usb:v24aep1411:name:*:
     MOUSE_DPI=2000@125
  '';

  # hub.rapoo.com uses WebHID; hidraw nodes are root-only by default on Linux.
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="24ae", TAG+="uaccess"
  '';

  # https://its-saanvi.github.io/linux-mcsr/drag-clicking.html
  # libinput debounces fast successive clicks by default; drag clicking needs that off.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Never Debounce]
    MatchUdevType=mouse
    ModelBouncingKeys=1
  '';

  console.keyMap = "pl2";

  security.rtkit.enable = true;

  # https://wiki.nixos.org/wiki/OBS_Studio — cudaSupport adds NVENC driver runpaths
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
    ];
  };

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
