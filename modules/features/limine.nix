{
  features.limine.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.nixos.limine;
    in
    {
      options.my.nixos.limine.maxGenerations = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "Maximum number of NixOS generations shown in the boot menu.";
      };

      config = {
        environment.systemPackages = [ pkgs.sbctl ];

        boot.loader = {
          systemd-boot.enable = lib.mkForce false;
          limine = {
            enable = true;
            enableEditor = false;
            secureBoot.enable = true;
            inherit (cfg) maxGenerations;
            extraEntries = ''
              /Windows Boot Manager
                protocol: efi
                path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
            '';
            style = {
              wallpapers = [ ];
              backdrop = "000000";
              interface = {
                helpHidden = true;
                brandingColor = "666666";
                helpColor = "444444";
                helpColorBright = "888888";
              };
              graphicalTerminal = {
                background = "ff000000";
                foreground = "cccccc";
                brightForeground = "ffffff";
                brightBackground = "333333";
              };
            };
          };
        };
      };
    };
}
