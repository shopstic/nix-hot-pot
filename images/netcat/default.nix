{ dockerTools
, netcat
, dumb-init
}:
let
  version = "3.4.3";
in
dockerTools.buildImage {
  name = "netcat";
  tag = version;
  config = {
    Entrypoint = [ "${dumb-init}/bin/dumb-init" "--" "${netcat}/bin/nc" ];
  };
}

