{ pkgs, ... }:
{
  imports = [
    ./wms
    ./browsers
    ./git
    ./gpg
    ./editors
  ];
  config = {
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
      # Clipboard
      grim
      slurp
      swappy
      wl-clipboard-rs

      # Dev Tools
      hyprpicker

      # Chat
      slack

      # Internal Utils
      twofctl

    ];
    programs = {
      k9s.enable = true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        config.global.hide_env_diff = true;
      };
    };

  };
}
