{ stdenv, jdk17, jdk17_headless, fetchurl }:
if stdenv.isDarwin then
  let
    dist = {
      aarch64-darwin = {
        arch = "aarch64";
        zuluVersion = "17.36.17";
        jdkVersion = "17.0.4.1";
        jdkSha256 = "sha256-R+J+OO0JJ52CbhTK5LW/kd2Tw+/CodGiAjW433SWTzQ=";
        jreSha256 = "sha256-liE+cpAH5QYQ2QyhvNTHvIM4+P4rb2z8JwKtAn6ANdE=";
      };
    }."${stdenv.hostPlatform.system}";
  in
  {
    jdk = jdk17.overrideAttrs (oldAttrs: {
      pname = "zulu${dist.zuluVersion}-ca-jdk";
      version = dist.jdkVersion;
      src = fetchurl {
        url = "https://cdn.azul.com/zulu/bin/zulu${dist.zuluVersion}-ca-jdk${dist.jdkVersion}-macosx_${dist.arch}.tar.gz";
        sha256 = dist.jdkSha256;
        curlOpts = "-H Referer:https://www.azul.com/downloads/zulu/";
      };
    });
    jre = jdk17.overrideAttrs (oldAttrs: {
      pname = "zulu${dist.zuluVersion}-ca-jre";
      version = dist.jdkVersion;
      src = fetchurl {
        url = "https://cdn.azul.com/zulu/bin/zulu${dist.zuluVersion}-ca-jre${dist.jdkVersion}-macosx_${dist.arch}.tar.gz";
        sha256 = dist.jreSha256;
        curlOpts = "-H Referer:https://www.azul.com/downloads/zulu/";
      };
      postFixup = "";
    });
  }
else
  {
    jdk = jdk17;
    jre = jdk17_headless;
  }
