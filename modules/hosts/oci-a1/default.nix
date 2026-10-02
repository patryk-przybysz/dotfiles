{ config, ... }:
{
  hosts.oci-a1 = {
    includes = [ config.features.nix ];

    nixos =
      { pkgs, ... }:
      {
        imports = [ ./_hardware-configuration.nix ];

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

        system.stateVersion = "26.05";
      };
  };
}
