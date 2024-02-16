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
        plugin = pkgs.vimPlugins.vim-closetag;
        file = ./vim-closetag.lua;
      })
    ];
  };
}
