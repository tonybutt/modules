{ pkgs, ... }:
{
  programs.k9s = {
    enable = true;
    plugin =
      let
        debug-command = pkgs.writeShellApplication {
          name = "debug";
          text = ''
            ${pkgs.kubectl}/bin/kubectl debug -it -n=$NAMESPACE $POD --target=$NAME --image=nicolaka/netshoot:v0.11 --share-processes -- bash
          '';
        };
        toggle-helmrelease = pkgs.writeShellApplication {
          name = "thr";
          text = ''
            ${pkgs.fluxcd}/bin/flux --context $CONTEXT $([ $(${pkgs.kubectl}/bin/kubectl --context $CONTEXT get helmreleases -n $NAMESPACE $NAME -o=custom-columns=TYPE:.spec.suspend | tail -1) = "true" ] && echo "resume" || echo "suspend") helmrelease -n $NAMESPACE $NAME |& less
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
        };
      };
  };

}
