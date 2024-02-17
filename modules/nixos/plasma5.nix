{ ... }:
{
  services.xserver = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = "plasmawayland";
    };

    desktopManager.plasma5.enable = true;
  };
  #programs.gnupg.agent.pinentryFlavor = "qt";
}
