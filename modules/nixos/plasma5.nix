{ ... }:
{
  services.xserver = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    desktopManager.plasma5.enable = true;
  };
  #programs.gnupg.agent.pinentryFlavor = "kde";
}
