{ lib, runCommand, writeTextFiles }:
{ user, uid, shellBin, group ? user, gid ? uid }:
writeTextFiles {
  "etc/shadow" = ''
    root:!x:::::::
    ${user}:!:::::::
  '';
  "etc/passwd" = ''
    root:x:0:0::/root:${shellBin}
    ${user}:x:${toString uid}:${toString gid}::/home/${user}:
  '';
  "etc/group" = ''
    root:x:0:0::/root:${shellBin}
    ${user}:x:${toString uid}:${toString gid}::/home/${user}:  
  '';
  "etc/gshadow" = ''
    root:x::
    ${user}:x::  
  '';
}
