{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.neovim = {
    # vimtex config
    plugins = [
      (config.lib.vimUtils.pluginWithCfg {
        plugin = pkgs.vimPlugins.vimtex;
        file = ./vimtex.lua;
      })
    ];

    # LSP config
    extraPackages = [ pkgs.texlab ];
  };
}
