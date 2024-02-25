{ config, pkgs, ... }:
{
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
        # (pkgs.uutils-coreutils.override { prefix = "u"; })
        # pkgs.alejandra
        pkgs.cowsay
        # pkgs.fd
        # pkgs.ffmpeg
        # pkgs.glow # markdown previewer in terminal
        # pkgs.grype
        # pkgs.httpie
        # pkgs.hugo # static site generator
        # pkgs.kotlin
        # pkgs.lazydocker
        # pkgs.ldns # replacement of `dig`, it provide the command `drill`
        # pkgs.nix
        # pkgs.nixfmt-rfc-style
        # pkgs.nixpkgs-fmt
        # pkgs.nodejs_20
        # pkgs.poetry
        # pkgs.rnix-lsp
        # pkgs.ruff
        # pkgs.stylua
        # pkgs.treefmt
        pkgs.age
        pkgs.aria2 # A lightweight multi-protocol & multi-source command-line download utility
        pkgs.atuin
        pkgs.autojump
        pkgs.bat
        pkgs.btop # replacement of htop/nmon
        pkgs.cachix
        pkgs.cb # defined in flake.nix
        pkgs.cirrus-cli
        pkgs.comma
        pkgs.coreutils-full
        pkgs.curl
        pkgs.diffutils
        pkgs.direnv
        pkgs.dnsutils # `dig` + `nslookup`
        pkgs.eza # A modern replacement for ‘ls’
        pkgs.file
        pkgs.findutils
        pkgs.fzf # A command-line fuzzy finder
        pkgs.gawk
        pkgs.gh
        pkgs.gnugrep
        pkgs.gnupg
        pkgs.gnused
        pkgs.gnutar
        pkgs.helm-docs
        pkgs.hurl
        pkgs.iftop # network monitoring
        pkgs.ipcalc # it is a calculator for the IPv4/v6 addresses
        pkgs.iperf3
        pkgs.jq # A lightweight and flexible command-line JSON processor
        pkgs.kubectl
        pkgs.kubectx
        pkgs.kubernetes-helm
        pkgs.kustomize
        pkgs.lsof # list open files
        pkgs.luajit
        pkgs.mmv
        pkgs.mtr # A network diagnostic tool
        pkgs.ncdu
        pkgs.neofetch
        pkgs.nil
        pkgs.nix-output-monitor
        pkgs.nmap # A utility for network discovery and security auditing
        pkgs.nnn # terminal file manager
        pkgs.p7zip
        pkgs.parallel
        pkgs.pciutils # lspci
        pkgs.pre-commit
        pkgs.ranger
        pkgs.rclone
        pkgs.restic
        pkgs.ripgrep # recursively searches directories for a regex pattern
        pkgs.rsync
        pkgs.shellcheck
        pkgs.socat # replacement of openbsd-netcat
        pkgs.starship
        pkgs.sysdo # defined in flake.nix
        pkgs.tree
        pkgs.which
        pkgs.xz
        pkgs.yq-go # yaml processer https://github.com/mikefarah/yq
        pkgs.zstd
        # python with default packages
        (pkgs.python3.withPackages (
          ps: [
            #ps.numpy
            #ps.scipy
            #ps.matplotlib
            #ps.networkx
          ]
        ))
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
    # java = {
    #   enable = false;
    #   package = pkgs.jdk21;
    # };
    k9s.enable = true;
    lazygit.enable = true;
    less.enable = true;
    man.enable = true;
    nix-index.enable = true;
    # pandoc.enable = true;
    ripgrep.enable = true;
    starship.enable = true;
    # yt-dlp.enable = true;
    zoxide.enable = true;
  };
}
