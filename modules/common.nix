{
  self,
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./primaryUser.nix
    ./nixpkgs.nix
  ];

  nixpkgs.overlays = builtins.attrValues self.overlays;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  user = {
    description = "bri";
    home = "${if pkgs.stdenvNoCC.isDarwin then "/Users" else "/home"}/${config.user.name}";
    shell = pkgs.zsh;
  };

  # bootstrap home manager using system config
  hm = {
    imports = [
      ./home-manager
      ./home-manager/1password.nix
      inputs.nix-index-database.hmModules.nix-index
    ];
  };

  # let nix manage home-manager profiles and use global nixpkgs
  home-manager = {
    extraSpecialArgs = {
      inherit self inputs;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  # environment setup
  environment = {
    systemPackages = [
      # editors
      pkgs.neovim

      # standard toolset
      pkgs.coreutils-full
      pkgs.findutils
      pkgs.diffutils
      pkgs.curl
      pkgs.wget
      pkgs.git
      pkgs.jq

      # helpful shell stuff
      pkgs.bat
      pkgs.fzf
      pkgs.ripgrep

      # languages
      pkgs.python3
      pkgs.ruby
      pkgs.shfmt

      # nix stuff
      pkgs.cachix
      pkgs.nil
      pkgs.nixfmt-rfc-style
      pkgs.home-manager
      inputs.attic.packages.${pkgs.system}.attic-client
    ];
    etc = {
      home-manager.source = "${inputs.home-manager}";
      nixpkgs.source = "${inputs.nixpkgs}";
      stable.source = "${inputs.stable}";
    };
    # list of acceptable shells in /etc/shells
    shells = [
      pkgs.bash
      pkgs.zsh
      pkgs.fish
    ];
  };

  fonts = {
    fontDir.enable = true;
    fonts = [ pkgs.jetbrains-mono ]; # fonts.fonts was _not_ renamed to fonts.packages in nix-darwin
  };
}
