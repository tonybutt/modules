{
  description = "A set of modules for work configuration.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.secondfront = {pkgs, ...}: {
      imports = [ ./nixos ];
    };
    homeManagerModules.secondfront = {pkgs, ...}: {
      imports = [ ./hm ];
    };
  };
}
