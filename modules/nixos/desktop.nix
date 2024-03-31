{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./mate.nix
    ./amdgpu.nix
  ];
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
    pkgs.trayscale
  ];

  # vscode = {
  #   enable = true;
  #   # extensions = [ pkgs.vscode-extensions.ms-vscode-remote ];
  #   package = pkgs.vscode.fhsWithPackages (
  #     ps: [
  #       ps.rustup
  #       ps.zlib
  #       ps.openssl.dev
  #       ps.pkg-config
  #     ]
  #   );
  # };
  home-manager.users.bri = {
    programs = {
      vscode = {
        enable = true;
        package = pkgs.vscode;
        #extensions = [ pkgs.vscode-extensions.ms-vscode-remote ];
      };
      chromium = {
        enable = true;
        package = pkgs.google-chrome;
        commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
      };
    };
  };
  # Electron applications use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui-beta;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "${config.user.name}" ];
  };
}
