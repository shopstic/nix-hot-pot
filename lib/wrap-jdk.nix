{ runCommand
, makeWrapper
, jdk
, args
}:
runCommand "wrapped-jdk"
{
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin

  find "${jdk}/" -mindepth 1 -maxdepth 1 -not -path "*/bin" -print0 | xargs -0 -I{} ln -s "{}" "$out/"
  find "${jdk}/bin/" -mindepth 1 -maxdepth 1 -print0 | xargs -0 -I{} ln -s "{}" "$out/bin/"

  wrapProgram "$out/bin/java" ${args}
''
