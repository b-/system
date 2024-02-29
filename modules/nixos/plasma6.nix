{ ... }:
{
  services.xserver = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = "plasma";
    };

    desktopManager.plasma6.enable = true;
  };
  #programs.gnupg.agent.pinentryFlavor = "qt";
}
