{
  inputs,
  config,
  pkgs,
  ...
}:
{
  nixpkgs = {
    config = import ./config.nix;
  };

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = {
      max-jobs = 8;
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
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "perchnet.cachix.org-1:0mwmOwJFqL+r4HKl68GZ90ATTFsi3/L4ejSUIWaYYmc="
        "bri.cachix.org-1:/dk2nWYOEZl/BnC8h5CTKgao5HeWjCIgY1Tuj29Bq4s="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
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
      nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        flake = inputs.nixpkgs;
      };
      stable = {
        from = {
          id = "stable";
          type = "indirect";
        };
        flake = inputs.stable;
      };
    };
  };
}
