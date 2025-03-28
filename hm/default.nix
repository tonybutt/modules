{ pkgs, lib, ... }:
{
  imports = [
    ./wms
    ./browsers
    ./git
    ./gpg
    ./editors
    ./shells
    ./launchers
  ];
  config = {
    stylix.targets.hyprlock.enable = lib.mkForce false;
    stylix.targets.hyprpaper.enable = lib.mkForce false;
    home.packages = with pkgs; [
      # DevOpts
      awscli2
      kind
      fluxcd
      kubectl
      kubelogin-oidc
      kubernetes-helm
      kustomize
      istioctl
      cilium-cli
      vim

      # Shell Utils
      tree
      jq
      yubikey-manager
      opensc

      # Clipboard
      grim
      slurp
      swappy
      wl-clipboard-rs

      # Dev Tools
      hyprpicker

      # Chat
      slack
    ];
    home.file."Wallpapers" = {
      recursive = true;
      source = ../stylix/assets/walls;
      target = "Wallpapers/Wallpapers/..";
    };
    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        config.global.hide_env_diff = true;
      };
      btop.enable = true;
      fzf = {
        enable = true;
        enableZshIntegration = true;
      };
      fastfetch.enable = true;
      cliphist = {
        enable = true;
        allowImages = true;
      };
    };
  };
}
