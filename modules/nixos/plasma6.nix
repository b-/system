{ pkgs, lib, ... }:
{
  services.xserver = {
    displayManager = {
      defaultSession = lib.mkOverride 800 "plasma";
    };

    desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = true;
    };
  };
  #programs.ssh.askPassword = lib.mkForce ${pkgs.kdePackages.ksshaskpass};
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

  environment.systemPackages = [
    pkgs.ktailctl
    pkgs.maliit-keyboard
  ];
  programs.gnupg.agent.pinentryFlavor = lib.mkForce "qt";
}
