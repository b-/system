{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };
  environment.systemPackages = [ pkgs.tailscale ];
}
