{ pkgs, lib, ... }:
{
  home = lib.mkIf pkgs.stdenv.isLinux {
    packages = [
      pkgs.ethtool
      pkgs.dconf
      pkgs.iotop # io monitoring
      pkgs.lm_sensors # for `sensors` command
      pkgs.ltrace # library call monitoring
      pkgs.strace # system call monitoring
      pkgs.usbutils # lsusb
      pkgs.unzip
      pkgs.zip
      pkgs.sysstat
    ];
  };
}
