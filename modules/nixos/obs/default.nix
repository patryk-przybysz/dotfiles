{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nixos.obs;
in
{
  options.my.nixos.obs.enable = lib.mkEnableOption "OBS Studio with NVENC";

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    };
  };
}
