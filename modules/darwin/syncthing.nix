{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.syncthing;
in
{
  options = {
    services.syncthing = {
      enable = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the Syncthing service.";
      };

      homeDir = lib.mkOption {
        type = types.nullOr types.path;
        default = "~";
        example = "/Users/bri";
        description = ''
          the base location for the syncthing folder
        '';
      };

      logDir = lib.mkOption {
        type = types.nullOr types.path;
        default = "~/Library/Logs";
        example = "~/Library/Logs";
        description = ''
          The logfile to use for the Syncthing service.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.syncthing ];
    launchd.user.agents.syncthing = {
      command = "${lib.getExe pkgs.syncthing}";
      serviceConfig = {
        Label = "net.syncthing.syncthing";
        KeepAlive = true;
        LowPriorityIO = true;
        ProcessType = "Background";
        StandardOutPath = "${cfg.logDir}/Syncthing.log";
        StandardErrorPath = "${cfg.logDir}/Syncthing-Errors.log";
        EnvironmentVariables = {
          NIX_PATH = "nixpkgs=" + toString pkgs.path;
          STNORESTART = "1";
        };
      };
    };
  };
}
