{
  description = "A set of modules for work configuration.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    treefmt.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt,
      systems,
      ...
    }@inputs:
    let
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = forEachSystem (pkgs: treefmt.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      nixosModules.secondfront =
        { inputs, ... }:
        {
          imports = [ ./nixos ];
        };
      homeManagerModules.secondfront =
        { inputs, ... }:
        {
          imports = [ ./hm ];
        };
    };
}
