{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.neovim = {
    plugins = [
      (config.lib.vimUtils.pluginWithCfg {
        plugin = pkgs.vimPlugins.awesome-vim-colorschemes;
        file = ./awesome-vim-colorschemes.lua;
      })
    ];
  };
}
