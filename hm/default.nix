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
    ./terminals
    ../stylix
  ];
  config = {
    stylix.targets.hyprlock.enable = lib.mkForce false;
    stylix.targets.hyprpaper.enable = lib.mkForce false;
    home =
      let
        patched_opensc = pkgs.opensc.overrideAttrs (_old: {
          version = "0.25.1";
          src = pkgs.fetchFromGitHub {
            owner = "OpenSC";
            repo = "OpenSC";
            rev = "0.25.1";
            sha256 = "sha256-Ktvp/9Hca87qWmDlQhFzvWsr7TvNpIAvOFS+4zTZbB8=";
          };
        });
      in
      {
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
          patched_opensc
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
        stateVersion = "25.05";
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
