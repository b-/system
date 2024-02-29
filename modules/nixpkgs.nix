{
  inputs,
  config,
  pkgs,
  self,
  ...
}:
{
  nixpkgs.config = {
    allowUnsupportedSystem = true;
    allowUnfree = true;
    allowBroken = false;
  };

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = {
      max-jobs = "auto";
      trusted-users = [
        "${config.user.name}"
        "root"
        "@admin"
        "@wheel"
      ];
      trusted-substituters = [
        "https://bri.cachix.org"
        "https://perchnet.cachix.org"
        "https://devenv.cachix.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "perchnet.cachix.org-1:0mwmOwJFqL+r4HKl68GZ90ATTFsi3/L4ejSUIWaYYmc="
        "bri.cachix.org-1:/dk2nWYOEZl/BnC8h5CTKgao5HeWjCIgY1Tuj29Bq4s="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      allowed-uris = [
        "github:hercules-ci/" # flake-parts
        "github:serokell/" # deploy-rs
        "github:cachix/" # cachix & devenv
        "github:nix-community/"
        "github:nixos/"
        "github:Mic92/" # nix-index-database
        "github:numtide/" # nixos-anywhere
        "github:lnl7/" # nix-darwin
        "github:zhaofengli/" # attic
        "github:ipetkov/crane/"

        # me
        "github:b-/"
        "github:briorg/"
        "github:perchnet/"

        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "https://github.com/"
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    nixPath = builtins.map (source: "${source}=/etc/${config.environment.etc.${source}.target}") [
      "home-manager"
      "nixpkgs"
      "stable"
    ];
    registry = {
      # nixpkgs.flake = inputs.nixpkgs; # fucky
      stable.flake = inputs.stable;
      system.flake = self;
    };
  };
}
