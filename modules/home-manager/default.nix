{ config, ... }:
{
  imports = [
    # ./kitty.nix
    ./bat.nix
    ./common.nix
    ./direnv.nix
    ./dotfiles
    ./fzf.nix
    ./git.nix
    ./nushell.nix
    ./nvim
    ./shell.nix
    ./ssh.nix
    ./tldr.nix
    ./tmux.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };
}
