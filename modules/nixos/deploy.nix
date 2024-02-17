{ pkgs, ... }:
{
  ## the following block is adapted from
  ## https://github.com/cole-h/nixos-config/blob/f31f40f8d97800ee2438be8ebe47aa5bb7ecff03/modules/config/deploy.nix
  users.groups.deploy = { };
  users.users.deploy = {
    isSystemUser = true;
    group = "deploy";
    shell = pkgs.bash;

    openssh.authorizedKeys.keys = [
      "no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIASj6aXKtcd6j0k/sZe5TQUcvOuL6yCMeFvieM9ce/+W deploy@1p"
    ];
  };

  security.sudo.extraRules = [
    {
      groups = [ "deploy" ];
      commands = [
        {
          command = "/nix/store/*/bin/switch-to-configuration";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = [ "NOPASSWD" ];
        }
        {
          command = ''/bin/sh -c "readlink -e /nix/var/nix/profiles/system || readlink -e /run/current-system"'';
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
