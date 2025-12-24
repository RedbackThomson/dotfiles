{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ (mylib.scanPaths ../base);
}
