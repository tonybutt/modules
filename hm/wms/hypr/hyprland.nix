{ config, lib, ... }:
let
  cfg = config.secondfront.hyprland;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  inherit (builtins) map toString;
in
{
  options = {
    secondfront.hyprland.enable = mkEnableOption "Enable hyprland window Manager" // {
      default = true;
    };
    secondfront.hyprland.monitors = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "DP-1";
            };
            width = mkOption {
              type = types.int;
              example = 1920;
            };
            height = mkOption {
              type = types.int;
              example = 1080;
            };
            refreshRate = mkOption {
              type = types.int;
              default = 60;
            };
            scale = mkOption {
              type = types.str;
              default = "1";
            };
            position = mkOption {
              type = types.str;
              default = "auto";
            };
            enabled = mkOption {
              type = types.bool;
              default = true;
            };
            workspace = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          };
        }
      );
      default = [ ];
    };
    secondfront.hyprland.mainMod = mkOption {
      type = types.str;
      default = "SUPER";
      example = "CTRL";
      description = "The main modifier key for Hyprland bindings.";
    };
  };
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      xwayland.enable = true;
      systemd = {
        enable = true;
        variables = [ "--all" ];
      };
      settings =
        let
          inherit (config.lib.stylix) colors;
          rgb = color: "rgb(${color})";
          activeGradient = "${rgb colors.base0B} ${rgb colors.base0A} 45deg";
          inactiveGradient = "${rgb colors.base00}";
          tabGradient = "${rgb colors.base00} ${rgb colors.base02}";
        in
        {
          "$mainMod" = cfg.mainMod;
          xwayland = {
            force_zero_scaling = true;
          };
          cursor = {
            no_hardware_cursors = true;
          };

          env = [
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "XDG_SESSION_DESKTOP,Hyprland"
          ];

          debug = {
            disable_logs = false;
            enable_stdout_logs = true;
          };

          input = {
            kb_layout = "us";
            numlock_by_default = true;
            follow_mouse = 1;

            touchpad = {
              natural_scroll = false;
            };

            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          };

          monitor =
            (map (
              m:
              "${m.name},${
                if m.enabled then
                  "${toString m.width}x${toString m.height}@${toString m.refreshRate},${m.position},${toString m.scale}"
                else
                  "disabled"
              }"
            ) (cfg.monitors))
            ++ [
              ",preferred,auto,1"
            ];
          general = {
            "col.active_border" = lib.mkDefault "${activeGradient}";
            "col.inactive_border" = lib.mkDefault "${inactiveGradient}";
            gaps_in = 1;
            gaps_out = 5;
            border_size = 2;

            layout = "dwindle";
          };

          decoration = {
            rounding = 6;

            blur = {
              enabled = false;
              size = 16;
              passes = 2;
              new_optimizations = true;
            };
            shadow = lib.mkForce { };
          };

          animations = {
            enabled = true;

            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            # bezier = "myBezier, 0.33, 0.82, 0.9, -0.08";

            animation = [
              "windows,     1, 7,  myBezier"
              "windowsOut,  1, 7,  default, popin 80%"
              "border,      1, 10, default"
              "borderangle, 1, 8,  default"
              "fade,        1, 7,  default"
              "workspaces,  1, 6,  default"
            ];
          };

          dwindle = {
            pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true; # you probably want this
          };
          group = {
            "col.border_active" = lib.mkDefault "${activeGradient}";
            "col.border_inactive" = lib.mkDefault "${inactiveGradient}";
            groupbar = {
              gradients = true;
              font_family = "OpenSans Bold";
              text_color = lib.mkDefault (rgb colors.base0B);
              "col.active" = lib.mkDefault "${tabGradient}";
              font_size = 28;
              height = 28;
              indicator_height = 1;
            };
          };
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
            workspace_swipe_invert = false;
            workspace_swipe_distance = 200;
            workspace_swipe_forever = true;
          };

          misc = {
            animate_manual_resizes = true;
            animate_mouse_windowdragging = true;
            enable_swallow = true;
            render_ahead_of_time = false;
            disable_hyprland_logo = true;
          };

          exec-once = [
            "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"
          ];
        };
    };
  };
}
