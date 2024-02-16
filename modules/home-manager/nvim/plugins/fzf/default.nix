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
        plugin = pkgs.vimPlugins.fzf-vim;
        file = ./fzf-vim.lua;
      })
    ];
    extraPackages = [ pkgs.fzf ];
  };
}
