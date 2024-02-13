{ lib }:
{
  security.sudo.wheelNeedsPassword = false;
  boot = {
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
  };
  services.qemuGuest.enable = lib.mkDefault true;
}
