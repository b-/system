{ ... }:
{
  services.xserver = {
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager.gnome.enable = true;
    programs.gnupg.agent.pinentryFlavor = "gnome3";
  };

  hm =
    { ... }:
    {
      imports = [ ../home-manager/gnome ];
    };
}
