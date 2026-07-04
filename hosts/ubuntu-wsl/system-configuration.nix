{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  services.userborn.enable = true;

  security.wrappers = {
    newuidmap = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.shadow.out}/bin/newuidmap";
    };
    newgidmap = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.shadow.out}/bin/newgidmap";
    };
  };

  users.users.patryk = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [
      "libvirt"
    ];
  };
}
