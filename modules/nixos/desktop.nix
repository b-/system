{ pkgs, config, ... }:
{
  # commented out because we import it at a higher hierarchical level
  #imports = [ ./keybase.nix ];

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
      enable = false;
      user = config.user.name;
      group = "users";
      openDefaultPorts = true;
      dataDir = config.user.home;
    };
  };

  environment.systemPackages = with pkgs; [
    vscode
    firefox
    google-chrome
    gnome.gnome-tweaks
  ];

  # Electron applications use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
