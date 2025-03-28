{
  pkgs,
  lib,
  user,
  ...
}:
{
  imports = [
    ./wms
    ./browsers
    ./git
    ./gpg
    ./editors
    ./shells
  ];
  config = {
    stylix.targets.hyprlock.enable = lib.mkForce false;
    stylix.targets.hyprpaper.enable = lib.mkForce false;
    home = {
      username = user.name;
      homeDirectory = "/home/${user.name}";
      packages = with pkgs; [
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
      file."Wallpapers" = {
        recursive = true;
        source = ../stylix/assets/walls;
        target = "Wallpapers/Wallpapers/..";
      };
    };
    services.cliphist = {
      enable = true;
      allowImages = true;
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
    };
  };
}
