{ ... }:
let
  brain = "192.168.30.40:9989";
in
{
  #users.extraUsers.buildbot-worker.extraGroups = [ "wheel" ]; # yes this is crazy, but sudo nixos-rebuild is the dumb way i'm testing/playing with it...
  #users.users.buildbot-worker.isSystemUser = true;
  services.buildbot-worker.enable = true;
  services.buildbot-worker.masterUrl = brain;
}
