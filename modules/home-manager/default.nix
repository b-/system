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
      packages = [
        pkgs.age

        pkgs.alejandra
        pkgs.atuin
        # pkgs.autojump
        pkgs.cachix
        pkgs.cb
        pkgs.cirrus-cli
        pkgs.comma
        pkgs.coreutils-full
        pkgs.curl
        pkgs.diffutils
        pkgs.fd
        pkgs.ffmpeg
        pkgs.findutils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.gnupg
        pkgs.gnused
        pkgs.grype
        pkgs.helm-docs
        pkgs.httpie
        pkgs.hurl
        pkgs.kotlin
        pkgs.kubectl
        pkgs.kubectx
        pkgs.kubernetes-helm
        pkgs.kustomize
        pkgs.lazydocker
        pkgs.luajit
        pkgs.mmv
        pkgs.ncdu
        pkgs.neofetch
        pkgs.nil
        pkgs.nix
        #pkgs.nixfmt
        pkgs.nixfmt-rfc-style
        pkgs.nixpkgs-fmt
        pkgs.nmap
        pkgs.nodejs_20
        pkgs.parallel
        pkgs.poetry
        pkgs.pre-commit
        # python with default packages
        (pkgs.python3.withPackages (
          ps: [
            ps.numpy
            ps.scipy
            ps.matplotlib
            ps.networkx
          ]
        ))
        pkgs.ranger
        pkgs.rclone
        pkgs.restic
        pkgs.rnix-lsp
        pkgs.rsync
        pkgs.ruff
        pkgs.shellcheck
        pkgs.starship
        pkgs.stylua
        pkgs.sysdo
        pkgs.tree
        pkgs.treefmt
        pkgs.trivy
        pkgs.yq-go
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
      # extensions = [ pkgs.vscode-extensions.ms-vscode-remote ];
      package = pkgs.vscode.fhsWithPackages (
        ps: [
          ps.rustup
          ps.zlib
          ps.openssl.dev
          ps.pkg-config
        ]
      );
    };
  };
}
