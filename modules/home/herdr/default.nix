{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.herdr;

  defaultShell = if config.programs.fish.enable then "${pkgs.fish}/bin/fish" else null;
in
{
  options.my.home.herdr.enable = lib.mkEnableOption "herdr terminal multiplexer";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.herdr
    ];

    xdg.configFile."herdr/config.toml".text = ''
      onboarding = false

      [theme]
      name = "tokyo-night"
      auto_switch = false

      [ui]
      show_agent_labels_on_pane_borders = true
      agent_panel_sort = "spaces"

      [ui.sound]
      enabled = false
    ''
    + lib.optionalString (defaultShell != null) ''
      # $SHELL stays bash (POSIX login); herdr panes use the enabled HM shell.
      [terminal]
      default_shell = "${defaultShell}"
      shell_mode = "login"
    '';
  };
}
