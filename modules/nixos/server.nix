{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  domain = "192.168.30.40";
in
{
  imports = [
    ./tsnsrv.nix
    ./gocd-agent.nix
    ./buildbot-controller.nix
    ./buildbot-worker.nix
  ];
  environment.systemPackages = [
    pkgs.hydra-cli
    pkgs.forgejo
    pkgs.gocd-server
  ];
  security.sudo.wheelNeedsPassword = false;
  boot = {
    growPartition = true;
    kernelParams = [
      "console=ttyS0,115200"
      "console=tty1"
    ];
  };
  services.code-server = {
    enable = true;
    port = 4444;
    host = "0.0.0.0";
    auth = "none";
  };
  services.gocd-server.enable = true;
  services.qemuGuest.enable = lib.mkDefault true;
  services.hydra = {
    enable = true;
    port = 3030;
    hydraURL = "http://${domain}:3030";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
    package = inputs.stable.legacyPackages."${pkgs.system}".hydra_unstable;
    # package = pkgs.hydra_unstable.overrideAttrs (
    #   old: {
    #     patches = (if old ? patches then old.patches else [ ]) ++ [
    #       ./hydra.patch # https://github.com/NixOS/nix/issues/7098#issuecomment-1910017187
    #     ];
    #   }
    # );
    extraConfig = ''
      <dynamicruncommand>
        enable = 1
      </dynamicruncommand>
      <runcommand>
        command = cat $HYDRA_JSON > /tmp/hydra-output
      </runcommand>
    '';
  };
  services.forgejo = lib.mkDefault {
    enable = true;
    settings = {
      service = {
        DISABLE_REGISTRATION = true;
      };
      server = {
        ROOT_URL = "https://${domain}:3000";
        LANDING_PAGE = "explore";
      };
    };
  };
  programs._1password.enable = true;
}
