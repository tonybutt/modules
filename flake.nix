{
  description = "A set of modules for work configuration.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    treefmt.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      nixpkgs,
      treefmt,
      systems,
      ...
    }:
    let
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      forEachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f (mkPkgs system));
      treefmtEval = forEachSystem (pkgs: treefmt.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      templates = forEachSystem (pkgs: {
        default = {
        path = ./templates/secondfront;
        description = "A basic host setup flake";
      }; });

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
