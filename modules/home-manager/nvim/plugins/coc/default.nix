{
  config,
  pkgs,
  lib,
  ...
}:
{
  # link coc-settings to the right location
  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;

  programs.neovim = {
    extraPackages = [
      pkgs.rubyPackages.solargraph
      pkgs.nodePackages.pyright
      pkgs.nil
      pkgs.fzf
    ];
    plugins = [
      (config.lib.vimUtils.pluginWithCfg {
        plugin = pkgs.vimPlugins.coc-nvim;
        file = ./coc-nvim.vim;
      })
      pkgs.vimPlugins.coc-css
      pkgs.vimPlugins.coc-eslint
      pkgs.vimPlugins.coc-fzf
      pkgs.vimPlugins.coc-git
      pkgs.vimPlugins.coc-go
      pkgs.vimPlugins.coc-html
      pkgs.vimPlugins.coc-java
      pkgs.vimPlugins.coc-json
      pkgs.vimPlugins.coc-lua
      pkgs.vimPlugins.coc-pairs
      pkgs.vimPlugins.coc-prettier
      pkgs.vimPlugins.coc-pyright
      pkgs.vimPlugins.coc-r-lsp
      pkgs.vimPlugins.coc-rls
      pkgs.vimPlugins.coc-smartf
      pkgs.vimPlugins.coc-snippets
      pkgs.vimPlugins.coc-solargraph
      pkgs.vimPlugins.coc-tslint
      pkgs.vimPlugins.coc-tsserver
      pkgs.vimPlugins.coc-vetur
      pkgs.vimPlugins.coc-vimlsp
      pkgs.vimPlugins.coc-vimtex
      pkgs.vimPlugins.coc-yaml
    ];
  };
}
