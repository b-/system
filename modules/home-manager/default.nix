{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs) stdenv;
  inherit (lib) mkIf;
in
{
  imports = [
    ./bat.nix
    ./direnv.nix
    ./dotfiles
    ./fzf.nix
    ./git.nix
    # ./kitty.nix
    ./nushell.nix
    ./nvim
    ./shell.nix
    ./ssh.nix
    ./tldr.nix
    ./tmux.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home =
    let
      NODE_GLOBAL = "${config.home.homeDirectory}/.node-packages";
    in
    {
      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      stateVersion = "22.05";
      sessionVariables = {
        GPG_TTY = "/dev/ttys000";
        EDITOR = "nvim";
        VISUAL = "nvim";
        CLICOLOR = 1;
        LSCOLORS = "ExFxBxDxCxegedabagacad";
        KAGGLE_CONFIG_DIR = "${config.xdg.configHome}/kaggle";
        NODE_PATH = "${NODE_GLOBAL}/lib";
      };
      sessionPath = [
        "${NODE_GLOBAL}/bin"
        "${config.home.homeDirectory}/.rd/bin"
        "${config.home.homeDirectory}/.local/bin"
      ];

      # define package definitions for current user environment
      packages = with pkgs; [
        age

        alejandra
        atuin
        # autojump
        cachix
        cb
        cirrus-cli
        comma
        coreutils-full
        curl
        diffutils
        fd
        ffmpeg
        findutils
        gawk
        gnugrep
        gnupg
        gnused
        grype
        helm-docs
        httpie
        hurl
        kotlin
        kubectl
        kubectx
        kubernetes-helm
        kustomize
        lazydocker
        luajit
        mmv
        ncdu
        neofetch
        nil
        nix
        #nixfmt
        nixfmt-rfc-style
        nixpkgs-fmt
        nmap
        nodejs_20
        parallel
        poetry
        pre-commit
        # python with default packages
        (python3.withPackages (
          ps: with ps; [
            numpy
            scipy
            matplotlib
            networkx
          ]
        ))
        ranger
        rclone
        restic
        rnix-lsp
        rsync
        ruff
        shellcheck
        starship
        stylua
        sysdo
        tree
        treefmt
        trivy
        yq-go
      ];
    };

  programs = {
    home-manager = {
      enable = true;
    };
    dircolors.enable = true;
    go.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
    k9s.enable = true;
    lazygit.enable = true;
    less.enable = true;
    man.enable = true;
    nix-index.enable = true;
    pandoc.enable = true;
    ripgrep.enable = true;
    starship.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;
    # conditionally enable vscode only on linux
    vscode = mkIf stdenv.isLinux {
      enable = true;
      # extensions = with pkgs.vscode-extensions; [ vscode-extensions.ms-vscode-remote ];
      package = pkgs.vscode.fhsWithPackages (
        ps: with ps; [
          rustup
          zlib
          openssl.dev
          pkg-config
        ]
      );
    };
  };
}
