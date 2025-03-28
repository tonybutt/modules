{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.secondfront.hyprland.enable {
    programs.mako.enable = true;
    programs.mako.defaultTimeout = 5000;
  };
}
