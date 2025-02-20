{ inputs, modulesPath, ... }:
let
  brain = "http://192.168.30.40:8153/go";
in
{
  users.extraUsers.gocd-agent.extraGroups = [ "wheel" ]; # yes this is crazy, but sudo nixos-rebuild is the dumb way i'm testing/playing with it...
  services.gocd-agent.enable = true;
  services.gocd-agent.goServer = brain;
  imports = [
    "${inputs.gocd-agent-nixpkgs}/nixos/modules/services/continuous-integration/gocd-agent/default.nix"
  ];
  disabledModules = [ "${modulesPath}/services/continuous-integration/gocd-agent/default.nix" ];
}
