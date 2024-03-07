{ ... }:
let
  githubSshKeyPath = ".ssh/github.pub";
  pveMacProSshKeyPath = ".ssh/pve-macpro.pub";
in
{
  programs.ssh = {
    enable = true;
    includes = [ "config.d/*" ];
    forwardAgent = true;
    extraConfig = ''
      IdentitiesOnly true
    '';
    matchBlocks = {
      "default" = {
        host = "*";
        identitiesOnly = true;
        identityFile = [ "~/${pveMacProSshKeyPath}" ];
      };
      "github" = {
        host = "gh: github: github.com";
        hostname = "github.com";
        user = "git";
        identityFile = "~/${githubSshKeyPath}";
      };
    };
  };
  home.file."${githubSshKeyPath}".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKeIqs+mKkXHZ5XUdb8SJ8U2eqjiQLojRFnMciwafE29";
  home.file."${pveMacProSshKeyPath}".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDx+KV/SW4RGIeKA2FHU9S7bZgnJMy77N6lBeo2n8sJ";
}
