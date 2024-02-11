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
    plugins = with pkgs.vimPlugins; [
      # basics
      vim-commentary

      vim-fugitive
      vim-nix

      vim-sandwich
      vim-sensible

      # vim addon utilities
      direnv-vim
      ranger-vim
      nvim-lspconfig
      mason-lspconfig-nvim
    ];
    extraConfig = ''
      ${config.lib.vimUtils.readVimConfig ./settings.lua}
      ${config.lib.vimUtils.readVimConfigRaw ./keybindings.lua}
    '';
  };
}
