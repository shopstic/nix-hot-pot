{ stdenv, jdk17, jdk17_headless }:
{
  jdk = jdk17;
  jre = jdk17_headless;
}
