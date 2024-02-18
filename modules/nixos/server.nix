{ lib, pkgs, ... }:
let
  domain = "192.168.30.40";
in
{
  environment.systemPackages = [
    pkgs.hydra-cli
    pkgs.forgejo
  ];
  security.sudo.wheelNeedsPassword = false;
  boot = {
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
  };
  services.qemuGuest.enable = lib.mkDefault true;
  services.hydra = {
    enable = true;
    port = 3030;
    hydraURL = "http://${domain}:3030";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
    package = pkgs.hydra_unstable.overrideAttrs (
      old: {
        patches = (if old ? patches then old.patches else [ ]) ++ [
          ./hydra.patch # https://github.com/NixOS/nix/issues/7098#issuecomment-1910017187
        ];
      }
    );
    extraConfig = ''
      evaluator_restrict_eval = false
    '';
  };
  services.forgejo = lib.mkDefault {
    enable = true;
    settings = {
      service = {
        DISABLE_REGISTRATION = true;
      };
      server = {
        ROOT_URL = "https://${domain}:3000";
        LANDING_PAGE = "explore";
      };
    };
  };
}
