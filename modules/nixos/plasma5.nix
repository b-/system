{...}: {
  services.xserver = {
    displayManager = {
      sddm.enable = true;
      desktopManager.plasma5.enable = true;
      sddm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager.plasma5.enable = true;
  };
}
