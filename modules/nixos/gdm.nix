{ ... }:
{
  services.xserver = {
    displayManager = {
      gdm = {
        enable = false;
        wayland = true;
      };
    };
  };
}
