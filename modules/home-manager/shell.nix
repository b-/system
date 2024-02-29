{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  functions = builtins.readFile ./functions.sh;
  aliases =
    rec {
      ls = "${pkgs.eza}/bin/eza --color=auto --classify=auto --git-repos --icons=auto";
      la = "${ls} -a";
      ll = "${ls} -la";
      lt = "${ls} -lat";
      ga = "git add";
      "ga." = "git add .";
      "-" = "cd -";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";
    }
    // lib.optionalAttrs pkgs.stdenvNoCC.isDarwin rec {
      # darwin specific aliases
      ibrew = "arch -x86_64 brew";
      abrew = "arch -arm64 brew";
    };
in
{
  # override programs.zsh while waiting for my `alias -- "foo=bar"` fix to hit upstream
  disabledModules = [ "${inputs.home-manager}/modules/programs/zsh.nix" ];
  imports = [ "${inputs.my-home-manager-fork}/modules/programs/zsh.nix" ];

  programs.zsh =
    let
      mkZshPlugin =
        {
          pkg,
          file ? "${pkg.pname}.plugin.zsh",
        }:
        rec {
          name = pkg.pname;
          src = pkg.src;
          inherit file;
        };
    in
    {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      localVariables = {
        LANG = "en_US.UTF-8";
        GPG_TTY = "/dev/ttys000";
        DEFAULT_USER = "${config.home.username}";
        CLICOLOR = 1;
        LS_COLORS = "ExFxBxDxCxegedabagacad";
        TERM = "xterm-256color";
      };
      shellAliases = aliases;
      initExtraBeforeCompInit = ''
        fpath+=~/.zfunc
      '';
      initExtra = ''
        ${functions}
        ${lib.optionalString pkgs.stdenvNoCC.isDarwin ''
          if [[ -d /opt/homebrew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
          fi
        ''}
        unset RPS1
      '';
      profileExtra = ''
        ${lib.optionalString pkgs.stdenvNoCC.isLinux "[[ -e /etc/profile ]] && source /etc/profile"}
      '';
      plugins = [
        (mkZshPlugin { pkg = pkgs.zsh-autopair; })
        (mkZshPlugin { pkg = pkgs.zsh-completions; })
        (mkZshPlugin { pkg = pkgs.zsh-autosuggestions; })
        (mkZshPlugin {
          pkg = pkgs.zsh-fast-syntax-highlighting;
          file = "fast-syntax-highlighting.plugin.zsh";
        })
        (mkZshPlugin { pkg = pkgs.zsh-history-substring-search; })
      ];
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "asdf"
        ];
      };
    };

  programs.bash = {
    enable = true;
    shellAliases = aliases;
    initExtra = ''
      ${functions}
      if [[ -d "${config.home.homeDirectory}/.asdf/" ]]; then
        . "${config.home.homeDirectory}/.asdf/asdf.sh"
        . "${config.home.homeDirectory}/.asdf/completions/asdf.bash"
      fi
    '';
  };

  # starship - a customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = false;
    };
  };

  #autojump - a 'cd' command that learns
  programs.autojump = {
    enable = true;
  };
}
