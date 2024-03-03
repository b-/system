{ lib, ... }:
{
  services.xserver = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = lib.mkOverride 1500 "plasmawayland";
    };

    desktopManager.plasma5.enable = true;
  };
  #programs.gnupg.agent.pinentryFlavor = "qt";
}
