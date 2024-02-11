{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [ inputs.attic.packages.x86_64-linux.attic-client ];
}
