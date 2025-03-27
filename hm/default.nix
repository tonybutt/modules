{pkgs, ...}:{
  imports = [
    ./wms
    ./browsers
    ./git
    ./gpg
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
      cilium
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
  };
}
