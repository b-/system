{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true; # update homebrew when running darwin-rebuild
      cleanup = "zap"; # removes unspecified brews
    };
    global = {
      brewfile = true;
    };
    brews = [
      "aria2"
      "atuin"
      "autojump"
      "bash"
      "bat"
      "pkg-config"
      "rom-tools" # supplies chdman
      "go"
      "just"
      "kubernetes-cli"
      "mame"
      "neovim"
      "stow"
      "thefuck"
      #"quartz-wm"
    ];

    taps = [
      "1password/tap"
      "beeftornado/rmtree"
      "cloudflare/cloudflare"
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "koekeishiya/formulae"
      "teamookla/speedtest"
    ];
  };
}
