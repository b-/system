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
    port = 3030;
    hydraURL = "http://${domain}:3030";
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
        ROOT_URL = "https://${domain}:3000";
        LANDING_PAGE = "explore";
      };
    };
  };
}
