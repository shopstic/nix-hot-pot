{ dockerTools
, gh-runner-token
, cacert
}:
dockerTools.buildImage {
  name = "gh-runner-token";
  tag = gh-runner-token.version;
  config = {
    Env = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    ];
    Entrypoint = [
      "${gh-runner-token}/bin/gh-runner-token"
    ];
  };
  contents = [
    gh-runner-token
    cacert
  ];
}

