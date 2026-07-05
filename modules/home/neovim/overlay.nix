{inputs}: final: prev:
with final.lib; let
  pkgs = final;

  pkgs-locked = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  mkNeovim = pkgs.callPackage ./mkNeovim.nix {
    inherit (pkgs-locked) wrapNeovimUnstable neovimUtils;
  };

  all-plugins = with pkgs.vimPlugins; [
    guess-indent-nvim
    copilot-vim
    which-key-nvim
    telescope-nvim
    telescope-fzf-native-nvim
    telescope-ui-select-nvim
    plenary-nvim
    nvim-web-devicons
    lazydev-nvim
    nvim-lspconfig
    fidget-nvim
    blink-cmp
    luasnip
    conform-nvim
    tokyonight-nvim
    todo-comments-nvim
    mini-nvim
    (nvim-treesitter.withPlugins (p: [
      p.bash
      p.c
      p.diff
      p.html
      p.javascript
      p.lua
      p.luadoc
      p.markdown
      p.markdown_inline
      p.nix
      p.query
      p.typescript
      p.vim
      p.vimdoc
    ]))
    nvim-autopairs
    indent-blankline-nvim
    nvim-lint
    nvim-treesitter-textobjects
    nvim-ts-context-commentstring
    nvim-unception
  ];

  extraPackages = with pkgs; [
    lua-language-server
    nil
    nixfmt
    typescript-language-server
    nodejs
    stylua
    prettierd
    markdownlint-cli2
    ripgrep
  ];
in {
  nvim = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  nvim-dev = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
    appName = "nvim-dev";
    wrapRc = false;
  };

  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };
}
