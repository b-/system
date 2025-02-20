{
  pkgs,
  config,
  lib,
  ...
}:
{
  # boot splash
  boot.plymouth.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      xkb.layout = "us";
      # services.xserver.xkbOptions = "eurosign:e";

      libinput = lib.mkDefault {
        # Enable touchpad support.
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
        };
      };
    };

    syncthing = {
      enable = false;
      user = config.user.name;
      group = "users";
      openDefaultPorts = true;
      dataDir = config.user.home;
    };
  };

  environment.systemPackages = [
    # pkgs.vscode
    pkgs.firefox
    pkgs.google-chrome
    pkgs.gnome.gnome-tweaks
  ];

  home-manager.users.bri.programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    #extensions = [ pkgs.vscode-extensions.ms-vscode-remote ];
  };
  # Electron applications use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable select unfree packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "discord"
      "google-chrome"
      "vscode"
    ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui-beta;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "${config.user.name}" ];
  };
}
