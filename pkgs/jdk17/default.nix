{ stdenv, jdk17, jdk17_headless, fetchurl }:
if stdenv.isDarwin then
  let
    dist = {
      aarch64-darwin = {
        arch = "aarch64";
        zuluVersion = "17.38.21";
        jdkVersion = "17.0.5";
        jdkSha256 = "sha256-UV3Vbsmbta6JZmIaIIiq375yYxgY/7um5Dh7fuKSqwk=";
        jreSha256 = "sha256-ML+9kmRtsZVekTEi5kwQ873FAm6usc+xhCZVHUeB3p0=";
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
