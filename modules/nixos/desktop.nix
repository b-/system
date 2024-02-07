{ pkgs, config, ... }:
{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      xkb.layout = "us";
      # services.xserver.xkbOptions = "eurosign:e";

      # Enable touchpad support.
      libinput.enable = true;
    };

    syncthing = {
      enable = true;
      user = config.user.name;
      group = "users";
      openDefaultPorts = true;
      dataDir = config.user.home;
    };
  };
  environment.systemPackages = with pkgs; [
    vscode
    firefox
    gnome.gnome-tweaks
  ];
}
