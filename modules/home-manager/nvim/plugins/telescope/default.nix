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
        plugin = pkgs.vimPlugins.telescope-nvim;
        file = ./telescope-nvim.lua;
      })
      pkgs.vimPlugins.telescope-fzf-native-nvim
      pkgs.vimPlugins.plenary-nvim
    ];
    extraPackages = [ pkgs.ripgrep ];
  };
}
