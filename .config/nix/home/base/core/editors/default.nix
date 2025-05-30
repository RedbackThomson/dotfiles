{
  mylib,
  pkgs-unstable,
  ...
}: {
  imports = mylib.scanPaths ./.;
}
