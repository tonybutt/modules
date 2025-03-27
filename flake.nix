{
  description = "A set of modules for work configuration.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    treefmt.url = "github:numtide/treefmt-nix";
    twofctl = {
      type = "gitlab";
      host = "code.il2.gamewarden.io";
      owner = "gamewarden%2Fplatform";
      repo = "2fctl";
    };
  };

  outputs =
    {
      nixpkgs,
      treefmt,
      systems,
      twofctl,
      ...
    }:
    let
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ twofctl.overlays.default ];
      };
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f (mkPkgs system));
      treefmtEval = forEachSystem (pkgs: treefmt.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      nixosModules.secondfront =
        { ... }:
        {
          imports = [ ./nixos ];
        };
      homeManagerModules.secondfront =
        { ... }:
        {
          imports = [ ./hm ];
        };
    };
}
