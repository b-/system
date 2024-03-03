{ pkgs, lib, ... }:
{
  home = lib.mkIf pkgs.stdenv.isDarwin {
  };
}
