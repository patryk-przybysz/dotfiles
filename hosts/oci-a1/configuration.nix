{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./minecraft/bingo.nix
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernel.sysctl."vm.mmap_rnd_bits" = 18;
  };

  networking = {
    hostName = "oci-a1";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Warsaw";

  programs.fish.enable = true;

  users.users.xvn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7FylCflQDXdb7Kjl+dAwaBPJPJvS6fGwLXD/BVJTuh"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    tmux
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
