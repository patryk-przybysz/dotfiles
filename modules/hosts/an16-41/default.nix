{ config, ... }:
{
  hosts.an16-41 = {
    includes = with config.features; [
      nix
      limine
      nvidia
      damx
      niri
      thunar
      alacritty
      noctalia
    ];

    nixos =
      { pkgs, ... }:
      let
        catppuccinSddm = pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          accent = "mauve";
        };
      in
      {
        imports = [ ./_hardware-configuration.nix ];

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
          loader.efi.canTouchEfiVariables = true;
          # Lets this laptop evaluate and build oci-a1.
          binfmt.emulatedSystems = [ "aarch64-linux" ];
        };

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

        fileSystems."/media/games/SteamLibrary/steamapps/compatdata" = {
          device = "/home/patryk/.steam/steam/steamapps/compatdata-games";
          fsType = "none";
          options = [
            "bind"
            "nofail"
          ];
        };

        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
        };

        networking = {
          hostName = "an16-41";
          networkmanager.enable = true;

          # DHCP/DNS for NetworkManager's shared AP. The Hotspot profile itself
          # lives in NetworkManager so nm-connection-editor can change it.
          firewall.interfaces.wlp4s0 = {
            allowedUDPPorts = [
              53
              67
            ];
            allowedTCPPorts = [ 53 ];
          };

          nat = {
            enable = true;
            internalIPs = [ "10.42.0.0/24" ];
            externalInterface = "enp3s0";
          };
        };

        environment.systemPackages = [ pkgs.networkmanagerapplet ];

        time.timeZone = "Europe/Warsaw";

        i18n.defaultLocale = "pl_PL.UTF-8";

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

        home-manager.backupFileExtension = "hm-bak";

        # Compx 2.4G wireless mouse: libinput can't detect its real DPI and assumes
        # 800, making everything ~2.5x too fast at the hardware's 2000 DPI.
        services.udev.extraHwdb = ''
          mouse:usb:v25a7pfa70:name:*:
           MOUSE_DPI=2000@125
        '';

        # WebHID hidraw ACL, installed before 73-seat-late.
        # Rapoo is 24ae. RK uses ENV because the vendor and interface are different parents.
        # Interface 01 is the configuration endpoint; the boot keyboard stays root-only.
        services.udev.packages = [
          (pkgs.writeTextFile {
            name = "rapoo-hidraw-rules";
            destination = "/etc/udev/rules.d/70-rapoo-hidraw.rules";
            text = ''
              ACTION!="remove", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", \
                ATTRS{idVendor}=="24ae", MODE="0660", TAG+="uaccess"
            '';
          })
          (pkgs.writeTextFile {
            name = "rk-hidraw-rules";
            destination = "/etc/udev/rules.d/70-rk-hidraw.rules";
            text = ''
              ACTION!="remove", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", \
                ENV{ID_VENDOR_ID}=="258a", ENV{ID_USB_INTERFACE_NUM}=="01", MODE="0660", TAG+="uaccess"
            '';
          })
        ];

        # https://its-saanvi.github.io/linux-mcsr/drag-clicking.html
        environment.etc."libinput/local-overrides.quirks".text = ''
          [Never Debounce]
          MatchUdevType=mouse
          ModelBouncingKeys=1
        '';

        console.keyMap = "pl2";

        security.rtkit.enable = true;

        users.users.patryk = {
          isNormalUser = true;
          description = "Patryk Przybysz";
          extraGroups = [
            "networkmanager"
            "wheel"
            "gamemode"
          ];
        };

        system.stateVersion = "26.05";
      };

    users.patryk = {
      includes = with config.features; [
        gaming
        gpu-screen-recorder
        mcsr
        obs
        haruna
        libreoffice
        qimgv
        vesktop
      ];

      # https://its-saanvi.github.io/linux-mcsr/tmpfs.html
      # https://github.com/flammablebunny/flake
      nixos.my.nixos.mcsr.tmpfs = {
        size = "4G";
        keepWorlds = 1000;
        instances = {
          RSG.savesPath = "/home/patryk/.local/share/PrismLauncher/instances/1.16.1 RSG/minecraft/saves";
          Ranked.savesPath = "/home/patryk/.local/share/PrismLauncher/instances/1.16.1 Ranked/minecraft/saves";
        };
      };

      homeManager =
        { pkgs, ... }:
        {
          home = {
            packages = [
              pkgs.spotify
            ];
            stateVersion = "26.05";
            language.base = "pl_PL.UTF-8";
          };

          programs.microsoft-edge = {
            enable = true;
            extensions = [
              "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
              "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
              "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
            ];
          };
        };
    };
  };
}
