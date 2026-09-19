# Drop when nixpkgs ships xwayland-satellite 0.8.3 or #564273.
# Steam menus close instantly on 0.8.2 (override-redirect focus steal).
final: prev: {
  xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch2 {
        name = "fix-dropdowns-closing-instantly.patch";
        url = "https://github.com/Supreeeme/xwayland-satellite/commit/add2795134593faafce60e404a0a75df68e9ee0c.diff?full_index=1";
        hash = "sha256-6QOZsE4/OoYjzNlzkzMmx6d9rcuh66AHjTBUqHnAWxU=";
      })
    ];
  });
}
