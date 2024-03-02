# TODO: move this into modules/home-manager/git.nix
{ ... }:
{
  programs.git = {
    userEmail = "284789+b-@users.noreply.github.com";
    userName = "bri";
    #    signing = {
    #      key = "kennan@case.edu";
    #      signByDefault = true;
    #    };
  };
}
