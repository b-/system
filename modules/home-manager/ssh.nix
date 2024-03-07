{ ... }:
{
  programs.ssh = {
    enable = true;
    includes = [ "config.d/*" ];
    forwardAgent = true;
    extraConfig = ''
      IdentitiesOnly true
    '';
  };
}
