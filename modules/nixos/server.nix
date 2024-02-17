{ lib, ... }:
let
  domain = "192.168.30.40";
in
{
  security.sudo.wheelNeedsPassword = false;
  boot = {
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
  };
  services.qemuGuest.enable = lib.mkDefault true;
  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };
  services.forgejo = lib.mkDefault {
    enable = true;
    settings = {
      service = {
        DISABLE_REGISTRATION = true;
      };
      server = {
        ROOT_URL = "https://${domain}";
        LANDING_PAGE = "explore";
      };
    };
  };
}