{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.hyprland;
  hypr-pkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  hypr-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  options = {
    modules.hyprland.enable = mkEnableOption "Enable hyprland module"// {
        default = true;
    };
  };
  config = mkIf cfg.enable {
    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --time --remember --remember-session --sessions ${pkgs.hyprland}/share/wayland-sessions";
            user = "${user.name}";
          };
        };
      };
      xserver = {
        enable = true;
        xkb.layout = "us";
      };
    };
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
    programs.hyprland = {
      enable = true;
      package = hypr-pkgs;
      portalPackage = hypr-pkgs.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };
    xdg.portal = {
      enable = true;
      config.common.default = [ "hyprland" ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        hypr-pkgs.xdg-desktop-portal-hyprland
      ];
    };
    hardware.graphics = {
      enable = true;
      package = hypr-nixpkgs.mesa;
      package32 = hypr-nixpkgs.pkgsi686Linux.mesa;
      enable32Bit = true;
    };
  };
}
