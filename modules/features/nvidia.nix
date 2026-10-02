{
  config,
  lib,
  ...
}:
let
  cfg = config.my.nixos.nvidia;
in
{
  options.my.nixos.nvidia.enable = lib.mkEnableOption "NVIDIA dGPU (hybrid with AMD iGPU)";

  config = lib.mkIf cfg.enable {
    # Still required to activate the nvidia module even on Wayland-only sessions
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Required for Wayland
      modesetting.enable = true;

      # NVIDIA-recommended open kernel modules (RTX 4060 is Ada, fully supported)
      open = true;

      # Full VRAM save/restore so suspend/hibernate doesn't corrupt graphics
      powerManagement.enable = true;
      # RTD3: dGPU deep-sleeps when unused (battery); first thing to disable
      # if power-offs around charger (un)plug or suspend weirdness appear
      powerManagement.finegrained = true;

      package = config.boot.kernelPackages.nvidiaPackages.production;

      # PRIME is X11-only; on niri/Wayland the compositor picks the render GPU
      # (AMD iGPU) and Proton/Vulkan select the dGPU per-game automatically.
      # This only provides the `nvidia-offload` wrapper for native Linux games.
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        # lspci: 01:00.0 NVIDIA, 66:00.0 AMD (hex 66 = 102)
        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:102:0:0";
      };
    };
  };
}
