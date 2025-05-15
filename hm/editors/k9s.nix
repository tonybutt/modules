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
        toggle = pkgs.writeShellApplication {
          name = "flux-toggle";
          text = ''
            CONTEXT=$1
            NAMESPACE=$2
            NAME=$3
            RESOURCE=$4
            suspended=$(${pkgs.kubectl}/bin/kubectl --context "$CONTEXT" get helmreleases -n "$NAMESPACE" "$NAME" -o=custom-columns=TYPE:.spec.suspend | tail -1)
            toggle=""
            if [ "$suspended" = "true" ]; then
              toggle="resume"
            else
              toggle="suspend"
            fi
            ${pkgs.fluxcd}/bin/flux "$toggle" --context "$CONTEXT" $RESOURCE -n "$NAMESPACE" "$NAME"
          '';
        };
        mkToggle = scope: resource: {
          shortCut = "Shift-T";
          description = "Suspend/Resume ${scope}";
          scopes = [ scope ];
          command = "${toggle}/bin/flux-toggle";
          background = true;
          args = [
            "$CONTEXT"
            "$NAMESPACE"
            "$NAME"
            resource
          ];
        };
        mkReconcile = command: resource: force: {
          shortCut = "Shift-R";
          confirm = false;
          description = "Flux reconcile";
          scopes = [ "${resource}" ];
          command = "${pkgs.bash}/bin/bash";
          background = true;
          args = [
            "-c"
            "${pkgs.fluxcd}/bin/flux --context $CONTEXT reconcile ${command} -n $NAMESPACE $NAME ${force} |& less"
          ];
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
        toggle-helmrelease = mkToggle "helmreleases" "hr";
        toggle-ks = mkToggle "kustomizations" "ks";
        reconcile-hr = mkReconcile "hr" "helmreleases" "";
        reconcile-hr-force = mkReconcile "hr" "helmreleases" "--force";
        reconcile-git = mkReconcile "source git" "gitrepositories" "";
        reconcile-helm = mkReconcile "source helm" "helmrepositories" "";
      };
  };

}
