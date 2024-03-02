{
  self,
  inputs,
  pkgs,
  ...
}:
{
  packages = [
    #pkgs.rnix-lsp
    pkgs.screen # to run disconnected
    pkgs.shfmt
    pkgs.nil
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    self.packages.${pkgs.system}.pyEnv
    (inputs.treefmt-nix.lib.mkWrapper pkgs (import ./treefmt.nix))
  ];

  pre-commit = {
    hooks = {
      black.enable = true;
      shellcheck.enable = true;
      nixfmt.enable = true;
      nixfmt.entry = pkgs.lib.mkForce "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
      alejandra.enable = false;
      deadnix.enable = true;
      shfmt.enable = true;
      stylua.enable = true;
    };

    settings = {
      deadnix.edit = true;
      deadnix.noLambdaArg = true;
    };
  };
}
