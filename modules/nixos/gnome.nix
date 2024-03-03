{ pkgs, ... }:
{
  services.xserver = {
    displayManager = {
      gdm = {
        enable = false;
        wayland = true;
      };
    };
    desktopManager.gnome.enable = true;
  };
  programs.gnupg.agent.pinentryFlavor = "gnome3";

  environment.systemPackages = [
    pkgs.gnome.gnome-tweaks
    pkgs.tailscale-systray
  ];

  hm =
    { ... }:
    {
      imports = [ ../home-manager/gnome ];
    };
}
