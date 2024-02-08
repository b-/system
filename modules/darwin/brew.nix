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
      "rom-tools" # supplies chdman
      "go"
      "just"
      "kubernetes-cli"
      "mame"
      "neovim"
      "oniguruma"
      "openssl@3"
      "stow"
      "thefuck"
      "tree-sitter"
      "unibilium"
      "xz"
      "yabai"
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
    casks = [
      "1password"
      "1password-cli"
      "appcleaner"
      "firefox-developer-edition"
      "fork"
      "google-chrome"
      "gpg-suite"
      "hammerspoon"
      "hot"
      "iina"
      "jetbrains-toolbox"
      "kitty"
      "obsidian"
      "raycast"
      # "rancher"
      "stats"
      "utm"
      "visual-studio-code"
      "zotero"
    ];
  };
}
