{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  services.userborn.enable = true;

  users.users.patryk = {
    isNormalUser = true;
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };
}
