{ nix2container
, karpenter
, cacert
}:
nix2container.buildImage {
  name = "karpenter-controller";
  tag = karpenter.version;
  config = {
    Env = [
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Entrypoint = [ "${karpenter.controller}/bin/controller" ];
  };
  maxLayers = 50;
}
