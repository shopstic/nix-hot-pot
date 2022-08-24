{ nix2container
, karpenter
, cacert
}:
nix2container.buildImage {
  name = "karpenter-webhook";
  tag = karpenter.version;
  config = {
    Env = [
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Entrypoint = [ "${karpenter.webhook}/bin/webhook" ];
  };
  maxLayers = 50;
}
