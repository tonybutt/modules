{ config, lib, ... }:
with lib;
let
  cfg = config.secondfront.hyprland;
in
{
  imports = mkIf cfg.enable [
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
  ];
  options = {
    secondfront.hyprland.enable = mkEnableOption "Enable hyprland window Manager" // {
      default = true;
    };
  };
}
