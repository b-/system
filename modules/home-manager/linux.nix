{ pkgs, lib, ... }:
# let
#   inherit (pkgs) stdenv;
#   inherit (lib) mkIf;
# in
{
  home = lib.mkIf pkgs.stdenv.isLinux {
    packages = [
      pkgs.ethtool
      pkgs.discord
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

    vscode = {
      enable = true;
      # extensions = [ pkgs.vscode-extensions.ms-vscode-remote ];
      package = pkgs.vscode.fhsWithPackages (
        ps: [
          ps.rustup
          ps.zlib
          ps.openssl.dev
          ps.pkg-config
        ]
      );
    };
  };
  programs.chromium = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    package = pkgs.google-chrome;
    commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
  };
}
