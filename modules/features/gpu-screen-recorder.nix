{
  features.gpu-screen-recorder = {
    nixos = {
      programs.gpu-screen-recorder = {
        enable = true;
        ui.enable = true;
      };
    };

    homeManager =
      { lib, pkgs, ... }:
      {
        # niri does not run XDG autostart; pin the overlay to the graphical session.
        systemd.user.services.gpu-screen-recorder-ui = {
          Unit = {
            Description = "GPU Screen Recorder overlay";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = lib.getExe pkgs.gpu-screen-recorder-ui;
            Restart = "on-failure";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
