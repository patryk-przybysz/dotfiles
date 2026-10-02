{ inputs, ... }:
{
  # Minecraft speedrunning packages + waywall HM/NixOS modules
  # https://git.uku3lig.net/uku/mcsr-nixos
  flake-file.inputs.mcsr = {
    url = "git+https://git.uku3lig.net/uku/mcsr-nixos.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  features.mcsr.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      mcsrPkgs = inputs.mcsr.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = [
        # NVIDIA: GLFW 65544 / preemptive need this on the game process.
        # https://tesselslate.github.io/waywall/00_setup.html#nvidia
        # Wrapped on the launcher so it applies without relying on Prism Env={}.
        (pkgs.symlinkJoin {
          name = "prismlauncher";
          paths = [
            (pkgs.prismlauncher.override {
              jdks = [
                mcsrPkgs.graalvm-21
                pkgs.temurin-bin-25
                pkgs.temurin-bin-21
                pkgs.temurin-bin-17
                pkgs.temurin-bin-8
              ];

              additionalLibs = with pkgs; [
                libx11
                libxt
                libxtst
                libxcb
                libxkbcommon
                libxinerama
              ];
            })
          ];
          nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
          postBuild = ''
            wrapProgram $out/bin/prismlauncher \
              --set __GL_THREADED_OPTIMIZATIONS 0
          '';
        })
        mcsrPkgs.modcheck
        mcsrPkgs.paceman-tracker
      ];

      # home-manager always has a programs.noctalia option, so check that Noctalia
      # is on in this home. mkAfter keeps the noctalia feature's plugins first.
      programs.noctalia = lib.mkIf config.programs.noctalia.enable {
        settings.plugins.enabled = lib.mkAfter [ "radimous/prismlauncher-instances" ];
      };
    };
}
