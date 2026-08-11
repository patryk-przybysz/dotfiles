{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.mpv;
in
{
  options.my.home.mpv.enable = lib.mkEnableOption "mpv media player with uosc UI";

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      # uosc = modern controls; thumbfast = seek preview; sponsorblock = skip YT sponsors
      scripts = with pkgs.mpvScripts; [
        uosc
        thumbfast
        sponsorblock
      ];

      config = {
        # Quality + hardware decode (VA-API / NVDEC / etc. when available)
        profile = "high-quality";
        hwdec = "auto-safe";
        vo = "gpu-next";

        # uosc owns the on-screen UI
        osc = "no";
        osd-bar = "no";
        border = "no";

        # Full-height window; width follows video aspect ratio
        geometry = "x100%";

        # Comfortable defaults for local files / recordings
        keep-open = "yes";
        save-position-on-quit = true;
        screenshot-directory = "~/Pictures/mpv";
        screenshot-template = "%F-%P";

        # Streaming (yt-dlp)
        ytdl-format = "bestvideo+bestaudio/best";

        # Subtitles
        sub-auto = "fuzzy";
        slang = "en,eng,pl,pol";
      };

      bindings = {
        WHEEL_UP = "seek 5";
        WHEEL_DOWN = "seek -5";
        "Alt+h" = "add video-pan-x 0.1";
        "Alt+l" = "add video-pan-x -0.1";
        "Alt+k" = "add video-pan-y 0.1";
        "Alt+j" = "add video-pan-y -0.1";
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
      };
    };
  };
}
