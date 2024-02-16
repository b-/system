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
        plugin = pkgs.vimPlugins.lualine-nvim;
        file = ./lualine-nvim.lua;
      })
    ];
  };
}
