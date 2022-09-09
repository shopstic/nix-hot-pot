{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, nix2container
, dumb-init
, cacert
, caddy
}:
let
  name = "caddy";
  user = "caddy";
  shadow = nonRootShadowSetup { inherit user; uid = 1000; shellBin = "/dev/false"; };
  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';
  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    paths = [
      dumb-init
      caddy
    ];
  };

  image =
    nix2container.buildImage
      {
        inherit name;
        tag = caddy.version;
        copyToRoot = [ nix-bin shadow home-dir ];
        maxLayers = 50;
        perms = [
          {
            path = home-dir;
            regex = "/home/${user}$";
            mode = "0777";
          }
        ];
        config = {
          volumes = {
            "/home/${user}" = { };
          };
          env = [
            "PATH=/bin"
            "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
          ];
          entrypoint = [ "dumb-init" "--" "caddy" "run" ];
          cmd = [ "--config" "/home/caddy/Caddyfile" "--adapter" "caddyfile" ];
          user = "${user}:${user}";
        };
      };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
