{ inputs, pkgs, ... }:
{
  environment.systemPackages = [ inputs.tsnsrv.packages.${pkgs.system}.default ];
}
# let
#   options = config.services.tsnsrv; in {
#     options = {
#       authKeyPath = mkOption {
#         description = "Path to a file containing a tailscale auth key. Make this a secret";
#         type = types.path;
#         default = defaults.authKeyPath;
#       };
# 
#       ephemeral = mkOption {
#         description = "Delete the tailnet participant shortly after it goes offline";
#         type = types.bool;
#         default = defaults.ephemeral;
#       };
# 
#       funnel = mkOption {
#         description = "Serve HTTP as a funnel, meaning that it is available on the public internet.";
#         type = types.bool;
#         default = false;
#       };
# 
#       insecureHTTPS = mkOption {
#         description = "Disable TLS certificate validation for requests from upstream. Insecure.";
#         type = types.bool;
#         default = false;
#       };
# 
#       listenAddr = mkOption {
#         description = "Address to listen on";
#         type = types.str;
#         default = defaults.listenAddr;
#       };
# 
#       loginServerUrl = lib.mkOption {
#         description = "Login server URL to use. If unset, defaults to the official tailscale service.";
#         default = config.services.tsnsrv.defaults.loginServerUrl;
#         type = with types; nullOr str;
#       };
# 
#       package = mkOption {
#         description = "Package to use for this tsnsrv service.";
#         default = config.services.tsnsrv.defaults.package;
#         type = types.package;
#       };
# 
#       plaintext = mkOption {
#         description = "Whether to serve non-TLS-encrypted plaintext HTTP";
#         type = types.bool;
#         default = false;
#       };
# 
#       certificateFile = mkOption {
#         description = "Custom certificate file to use for TLS listening instead of Tailscale's builtin way";
#         type = with types; nullOr path;
#         default = defaults.certificateFile;
#       };
# 
#       certificateKey = mkOption {
#         description = "Custom key file to use for TLS listening instead of Tailscale's builtin way.";
#         type = with types; nullOr path;
#         default = defaults.certificateKey;
#       };
# 
#       acmeHost = mkOption {
#         description = "Populate certificateFile and certificateKey option from this certifcate name from security.acme module.";
#         type = with types; nullOr str;
#         default = defaults.acmeHost;
#       };
# 
#       upstreamUnixAddr = mkOption {
#         description = "Connect only to the given UNIX Domain Socket";
#         type = types.nullOr types.path;
#         default = null;
#       };
# 
#       prefixes = mkOption {
#         description = "URL path prefixes to allow in forwarding. Acts as an allowlist but if unset, all prefixes are allowed.";
#         type = types.listOf types.str;
#         default = [ ];
#       };
# 
#       stripPrefix = mkOption {
#         description = "Strip matched prefix from request to upstream. Probably should be true when allowlisting multiple prefixes.";
#         type = types.bool;
#         default = true;
#       };
# 
#       whoisTimeout = mkOption {
#         description = "Maximum amount of time that a requestor lookup may take.";
#         type = types.nullOr types.str;
#         default = null;
#       };
# 
#       suppressWhois = mkOption {
#         description = "Disable passing requestor information to upstream service";
#         type = types.bool;
#         default = false;
#       };
# 
#       upstreamHeaders = mkOption {
#         description = "Headers to set on requests to upstream.";
#         type = types.attrsOf types.str;
#         default = { };
#       };
# 
#       suppressTailnetDialer = mkOption {
#         description = "Disable using the tsnet-provided dialer, which can sometimes cause issues hitting addresses outside the tailnet";
#         type = types.bool;
#         default = false;
#       };
# 
#       readHeaderTimeout = mkOption {
#         description = "";
#         type = types.nullOr types.str;
#         default = null;
#       };
# 
#       toURL = mkOption {
#         description = "URL to forward HTTP requests to";
#         type = types.str;
#       };
# 
#       supplementalGroups = mkOption {
#         description = "List of groups to run the service under (in addition to the 'tsnsrv' group)";
#         type = types.listOf types.str;
#         default = defaults.supplementalGroups;
#       };
# 
#       timeout = mkOption {
#         description = "Maximum amount of time that authenticating to the tailscale API may take";
#         type = with types; nullOr str;
#         default = defaults.timeout;
#       };
# 
#       tsnetVerbose = mkOption {
#         description = "Whether to log verbosely from tsnet. Can be useful for seeing first-time authentication URLs.";
#         type = types.bool;
#         default = defaults.tsnetVerbose;
#       };
# 
#       extraArgs = mkOption {
#         description = "Extra arguments to pass to this tsnsrv process.";
#         type = types.listOf types.str;
#         default = [ ];
#       };
#     };
# 
#   serviceArgs =
#     { name, service }:
#     let
#       readHeaderTimeout =
#         if service.readHeaderTimeout == null then
#           if service.funnel then "1s" else "0s"
#         else
#           service.readHeaderTimeout;
#     in
#     [
#       "-name=${name}"
#       "-ephemeral=${lib.boolToString service.ephemeral}"
#       "-funnel=${lib.boolToString service.funnel}"
#       "-plaintext=${lib.boolToString service.plaintext}"
#       "-listenAddr=${service.listenAddr}"
#       "-stripPrefix=${lib.boolToString service.stripPrefix}"
#       "-authkeyPath=${service.authKeyPath}"
#       "-insecureHTTPS=${lib.boolToString service.insecureHTTPS}"
#       "-suppressTailnetDialer=${lib.boolToString service.suppressTailnetDialer}"
#       "-readHeaderTimeout=${readHeaderTimeout}"
#       "-tsnetVerbose=${lib.boolToString service.tsnetVerbose}"
#     ]
#     ++ lib.optionals (service.whoisTimeout != null) [
#       "-whoisTimeout"
#       service.whoisTimeout
#     ]
#     ++ lib.optionals (service.upstreamUnixAddr != null) [
#       "-upstreamUnixAddr"
#       service.upstreamUnixAddr
#     ]
#     ++ lib.optionals (service.certificateFile != null && service.certificateKey != null) [
#       "-certificateFile=${service.certificateFile}"
#       "-keyFile=${service.certificateKey}"
#     ]
#     ++ lib.optionals (service.timeout != null) [ "-timeout=${service.timeout}" ]
#     ++ map (p: "-prefix=${p}") service.prefixes
#     ++ map (h: "-upstreamHeader=${h}") (
#       lib.mapAttrsToList (name: service: "${name}: ${service}") service.upstreamHeaders
#     )
#     ++ service.extraArgs
#     ++ [ service.toURL ];
# in
# {
#   options = with lib; {
#     services.tsnsrv.enable = mkOption {
#       description = "Enable tsnsrv";
#       type = types.bool;
#       default = false;
#     };
# 
#     services.tsnsrv.defaults = {
#       package = mkOption {
#         description = "Package to run tsnsrv out of";
#         default = flake.packages.${pkgs.stdenv.targetPlatform.system}.tsnsrv;
#         type = types.package;
#       };
# 
#       authKeyPath = lib.mkOption {
#         description = "Path to a file containing a tailscale auth key. Make this a secret";
#         type = types.path;
#       };
# 
#       acmeHost = mkOption {
#         description = "Populate certificateFile and certificateKey option from this certifcate name from security.acme module.";
#         type = with types; nullOr str;
#         default = null;
#       };
# 
#       certificateFile = mkOption {
#         description = "Custom certificate file to use for TLS listening instead of Tailscale's builtin way";
#         type = with types; nullOr path;
#         default = null;
#       };
# 
#       certificateKey = mkOption {
#         description = "Custom key file to use for TLS listening instead of Tailscale's builtin way.";
#         type = with types; nullOr path;
#         default = null;
#       };
# 
#       ephemeral = mkOption {
#         description = "Delete the tailnet participant shortly after it goes offline";
#         type = types.bool;
#         default = false;
#       };
# 
#       listenAddr = mkOption {
#         description = "Address to listen on";
#         type = types.str;
#         default = ":443";
#       };
# 
#       loginServerUrl = lib.mkOption {
#         description = "Login server URL to use. If unset, defaults to the official tailscale service.";
#         default = null;
#         type = with types; nullOr str;
#       };
# 
#       supplementalGroups = mkOption {
#         description = "List of groups to run the service under (in addition to the 'tsnsrv' group)";
#         type = types.listOf types.str;
#         default = [ ];
#       };
# 
#       timeout = mkOption {
#         description = "Maximum amount of time that authenticating to the tailscale API may take";
#         type = with types; nullOr str;
#         default = null;
#       };
# 
#       tsnetVerbose = mkOption {
#         description = "Whether to log verbosely from tsnet. Can be useful for seeing first-time authentication URLs.";
#         type = types.bool;
#         default = false;
#       };
#     };
# 
#     services.tsnsrv.services = mkOption {
#       description = "tsnsrv services";
#       default = { };
#       type = types.attrsOf (types.submodule serviceSubmodule);
#       example = false;
#     };
# 
#     virtualisation.oci-sidecars.tsnsrv = {
#       enable = mkEnableOption "tsnsrv oci sidecar containers";
# 
#       authKeyPath = mkOption {
#         description = "Path to a file containing a tailscale auth key. Make this a secret";
#         type = types.path;
#         default = config.services.tsnsrv.defaults.authKeyPath;
#       };
# 
#       containers = mkOption {
#         description = "Attrset mapping sidecar container names to their respective tsnsrv service definition. Each sidecar container will be attached to the container it belongs to, sharing its network.";
#         type = types.attrsOf (
#           types.submodule {
#             options = {
#               name = mkOption {
#                 description = "Name to use for the tsnet service. This defaults to the container name.";
#                 type = types.nullOr types.str;
#                 default = null;
#               };
# 
#               forContainer = mkOption {
#                 description = "The container to which to attach the sidecar.";
#                 type = types.str; # TODO: see if we can constrain this to all the oci containers in the system definition, with types.oneOf or an appropriate check.
#               };
# 
#               service = mkOption {
#                 description = "tsnsrv service definition for the sidecar.";
#                 type = types.submodule serviceSubmodule;
#               };
#             };
#           }
#         );
#       };
#     };
#   };
# }
