{
  self,
  inputs,
  pkgs,
  ...
}: {
  packages = [
    pkgs.rnix-lsp
    pkgs.nil
    self.packages.${pkgs.system}.pyEnv
    (inputs.treefmt-nix.lib.mkWrapper pkgs (import ./treefmt.nix))
  ];

  pre-commit = {
    hooks = {
      black.enable = true;
      shellcheck.enable = true;
      #nixfmt.enable = true;
      alejandra.enable = true;
      deadnix.enable = true;
      shfmt.enable = false;
      stylua.enable = true;
    };

    settings = {
      deadnix.edit = true;
      deadnix.noLambdaArg = true;
    };
  };
}
