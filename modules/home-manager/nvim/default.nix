{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./plugins ];

  lib.vimUtils = rec {
    # For plugins configured with lua
    wrapLuaConfig = luaConfig: ''
      lua<<EOF
      ${luaConfig}
      EOF
    '';
    readVimConfigRaw =
      file:
      if (lib.strings.hasSuffix ".lua" (builtins.toString file)) then
        wrapLuaConfig (builtins.readFile file)
      else
        builtins.readFile file;
    readVimConfig = file: ''
      if !exists('g:vscode')
        ${readVimConfigRaw file}
      endif
    '';
    pluginWithCfg =
      { plugin, file }:
      {
        inherit plugin;
        config = readVimConfig file;
      };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # nvim plugin providers
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;

    # share vim plugins since nothing is specific to nvim
    plugins = [
      # basics
      pkgs.vimPlugins.vim-commentary

      pkgs.vimPlugins.vim-fugitive
      pkgs.vimPlugins.vim-nix

      pkgs.vimPlugins.vim-sandwich
      pkgs.vimPlugins.vim-sensible

      # vim addon utilities
      pkgs.vimPlugins.direnv-vim
      pkgs.vimPlugins.ranger-vim
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.mason-lspconfig-nvim
    ];
    extraConfig = ''
      ${config.lib.vimUtils.readVimConfig ./settings.lua}
      ${config.lib.vimUtils.readVimConfigRaw ./keybindings.lua}
    '';
  };
}
