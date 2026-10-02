{
  pkgs,
  inputs,
  ...
}:
let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  yabu = pkgs.fetchModrinthModpack {
    url = "https://cdn.modrinth.com/data/oMMOxJjh/versions/5Th4NGrW/Yet%20Another%20Bingo%3A%20Ultimate-2.9.6.mrpack";
    packHash = "sha256-cG0dgm9K5rpK1xsxvZtAhzxwWMXnU4bVLuzUjeh7tT8=";
    side = "server";
  };
in
{
  services.minecraft-servers.servers.bingo = {
    enable = true;
    package = pkgs.fabricServers.fabric-1_21_11.override {
      loaderVersion = "0.18.4";
    };
    jvmOpts = "-Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
    serverProperties = {
      motd = "§6xvers.one §8· §fbingo nix btw";
      white-list = true;
      online-mode = true;
      "pause-when-empty-seconds" = 3600;
      difficulty = 1;
      view-distance = 12;
      simulation-distance = 12;
      spawn-protection = 0;
    };
    operators = {
      xversone = "9492b85c-5dda-4eba-b6f7-50036390033f";
    };
    symlinks = collectFilesAt yabu "mods" // {
      "mods/chunky.jar" = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/fALzjamp/versions/1CpEkmcD/Chunky-Fabric-1.4.55.jar";
        sha256 = "sha256-M8vZvODjNmhRxLWYYQQzNOt8GJIkjx7xFAO77bR2vRU=";
      };
    };
    files = collectFilesAt yabu "config" // {
      "config/chunky/config.json".value = {
        forceLoadExistingChunks = true;
      };
      "config/yet-another-minecraft-bingo/chunky.json".value = {
        enabled = true;
        chunkyWorlds = {
          "minecraft:overworld" = 1000;
          "minecraft:the_nether" = 500;
        };
      };
      "world/datapacks/smant.zip" = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/4y2r0obJ/versions/SEgoqdas/YAMB-Smant-1.21.11.zip";
        sha256 = "sha256-AFwdWPEAhiZajw7+gff1j3utYyvWgtQ69Kn9+hdGI8o=";
      };
    };
  };
}
