{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.tree-sitter ];
  programs.neovim = {
    plugins = [
      # new neovim stuff
      (config.lib.vimUtils.pluginWithCfg {
        plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        file = ./nvim-treesitter.lua;
      })
      (config.lib.vimUtils.pluginWithCfg {
        plugin = pkgs.vimPlugins.nvim-treesitter-textobjects;
        file = ./nvim-treesitter-textobjects.lua;
      })
    ];
  };
}
