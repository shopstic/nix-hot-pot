{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, nix2container
, dumb-init
, ng-server
}:
let
  name = "ng-server";
  user = "ng-server";
  userUid = 1000;
  shadow = nonRootShadowSetup { inherit user; uid = userUid; shellBin = "/dev/false"; };
  root-env = buildEnv {
    name = "root-env";
    pathsToLink = [ "/bin" ];
    paths = [
      dumb-init
      ng-server
    ];
    postBuild = ''
      mkdir -p $out/home/${user}
      cp -R ${shadow}/. $out/
    '';
  };

  image =
    nix2container.buildImage
      {
        inherit name;
        tag = ng-server.version;
        copyToRoot = [ root-env ];
        maxLayers = 50;
        perms = [
          {
            path = root-env;
            regex = "/home/${user}";
            mode = "0755";
            gid = userUid;
            uid = userUid;
          }
        ];
        config = {
          volumes = {
            "/home/${user}" = { };
          };
          env = [
            "PATH=/bin"
          ];
          entrypoint = [ "dumb-init" "--" "ng-server" ];
          user = "${user}:${user}";
        };
      };
in
image
