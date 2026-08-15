{
  myvars,
  config,
  pkgs,
  ...
}:
{
  # Don't allow mutation of users outside the config.
  users.mutableUsers = false;

  # home-manager configures zsh for these hosts, but the login shell is a NixOS
  # setting; without this the user lands in bash and no zsh config is ever
  # sourced. mutableUsers = false rules out chsh as an escape hatch, and
  # programs.zsh.enable is what puts zsh in /etc/shells.
  programs.zsh.enable = true;

  users.groups = {
    "${myvars.username}" = { };
  };

  users.users."${myvars.username}" = {
    # we have to use initialHashedPassword here when using tmpfs for /
    inherit (myvars) initialHashedPassword;
    home = "/home/${myvars.username}";
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      myvars.username
      "users"
      "wheel"
    ];
  };

  # root's ssh key are mainly used for remote deployment
  users.users.root = {
    inherit (myvars) initialHashedPassword;
    openssh.authorizedKeys.keys = myvars.sshAuthorizedKeys;
  };
}
