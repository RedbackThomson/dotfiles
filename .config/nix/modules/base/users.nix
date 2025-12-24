{
  myvars,
  ...
}: {
  users.users.${myvars.username} = {
    description = myvars.userfullname;

    openssh.authorizedKeys.keys = myvars.sshAuthorizedKeys;
  };
}
