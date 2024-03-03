{ lib, ... }:
{
  services.xserver = {

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = lib.mkDefault "plasma";
    };
  };
}
