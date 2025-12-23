{lib, ...}: {
  options.myconfig.languages = {
    bun.enable = lib.mkEnableOption "Bun JavaScript runtime";
    go.enable = lib.mkEnableOption "Go programming language";
    rust.enable = lib.mkEnableOption "Rust programming language";
    python.enable = lib.mkEnableOption "Python programming language";
    kcl.enable = lib.mkEnableOption "KCL configuration language";
  };
}
