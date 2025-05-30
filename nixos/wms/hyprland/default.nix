{
  pkgs,
  config,
  lib,
  inputs,
  user,
  ...
}:
with lib;
let
  cfg = config.modules.hyprland;
in
{
  options = {
    modules.hyprland.enable = mkEnableOption "Enable hyprland module" // {
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
      xwayland.enable = true;
    };
    xdg.portal = {
      enable = true;
      config.common.default = [ "hyprland" ];
    };
    hardware = {
      nvidia = {
        open = true;
        powerManagement.enable = true;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
