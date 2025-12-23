{mylib, ...}: {
  imports = [
    ./options.nix
  ] ++ mylib.scanPaths ./.;
}
