{ pkgs, ... }:
{
  programs.k9s = {
    enable = true;
    plugin =
      let
        debug-command = pkgs.writeShellApplication {
          name = "debug";
          text = ''
            ${pkgs.kubectl}/bin/kubectl debug -it -n="$NAMESPACE" "$POD" --target="$NAME" --image=nicolaka/netshoot:v0.11 --share-processes -- bash
          '';
        };
        toggle-helmrelease = pkgs.writeShellApplication {
          name = "thr";
          text = ''
            CONTEXT=$1
            NAMESPACE=$2
            NAME=$3
            suspended=$(${pkgs.kubectl}/bin/kubectl --context "$CONTEXT" get helmreleases -n "$NAMESPACE" "$NAME" -o=custom-columns=TYPE:.spec.suspend | tail -1)
            toggle=""
            if [ "$suspended" = "true" ]; then
              toggle="resume"
            else
              toggle="suspend"
            fi
            ${pkgs.fluxcd}/bin/flux "$toggle" --context "$CONTEXT" hr -n "$NAMESPACE" "$NAME"
          '';
        };
      in
      {
        debug = {
          shortCut = "Shift-D";
          description = "Add debug container";
          scopes = [ "containers" ];
          command = "${debug-command}/bin/debug";
          background = false;
          confirm = true;
        };
        toggle-helmrelease = {
          shortCut = "Shift-T";
          description = "Suspend/Resume HR";
          scopes = [ "helmreleases" ];
          command = "${toggle-helmrelease}/bin/thr";
          background = true;
          args = [
            "$CONTEXT"
            "$NAMESPACE"
            "$NAME"
          ];
        };
      };
  };

}
