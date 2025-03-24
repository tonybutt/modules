{ ... }:
{
  projectRootFile = "flake.nix";
  programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    nixfmt.priority = 1;
  };
}
