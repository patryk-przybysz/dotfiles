{
  # Only used so other inputs can follow it.
  flake-file.inputs.systems.url = "github:nix-systems/default";

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
}
