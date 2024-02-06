{...}: {
  services.xserver = {
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager.gnome.enable = true;
  };

  hm = {...}: {
    imports = [../home-manager/gnome];
  };
}
