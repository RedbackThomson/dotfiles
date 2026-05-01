{config, lib, pkgs, ...}: {
  home.packages = with pkgs; []
    ++ (if config.myconfig.databases.mongodb.enable then [mongosh] else [])
    ++ (if config.myconfig.databases.postgresql.enable then [pgcli] else [])
    ++ (if config.myconfig.databases.mysql.enable then [mycli] else [])
    ++ (if config.myconfig.databases.sqlite.enable then [sqlite] else []);
}
