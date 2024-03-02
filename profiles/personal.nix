# TODO: move this into modules/home-manager/git.nix
{ ... }:
{
  user.name = "bri";
  hm = {
    imports = [ ./home-manager/personal.nix ];
  };
}
