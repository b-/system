{
  pkgs,
  lib,
  options,
  ...
}:
let
  cde-icons = pkgs.writeShellScriptBin "cde-icons" ''
    file=`basename ''${1%.*}`

    ${pkgs.imagemagick}/bin/convert $1 -resize 48x48 ~/.dt/icons/$file.l.pm
    ${pkgs.imagemagick}/bin/convert $1 -resize 32x32 ~/.dt/icons/$file.m.pm
    ${pkgs.imagemagick}/bin/convert $1 -resize 24x24 ~/.dt/icons/$file.s.pm
    ${pkgs.imagemagick}/bin/convert $1 -resize 16x16 ~/.dt/icons/$file.t.pm
  '';
  cde-battery = pkgs.writeScriptBin "cde-battery" ''
    #!${pkgs.cdesktopenv}/opt/dt/bin/dtksh
    ${pkgs.lib.readFile (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/edorig/dtksh/5f49e402b391c81ebea9609bdec9c7716e70a8c0/battery";
        sha256 = "0zjn9zl1as9xbk2845bbdy2xfj29b4hvvalcz8kf2llkndbfswvl";
      }
    )}
  '';
in
{
  services.xserver.desktopManager.cde.enable = true;
  services.xserver.desktopManager.cde.extraPackages =
    with pkgs;
    options.services.xserver.desktopManager.cde.extraPackages.default
    ++ [
      fsv
      cde-icons
      #cde-gtk-theme # not working
      cde-battery
    ];
}
