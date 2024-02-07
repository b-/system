{ ... }:
{
  homebrew = {
    enable = true;
    global = {
      brewfile = true;
    };
    brews = [ ];

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
