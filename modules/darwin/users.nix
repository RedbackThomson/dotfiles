{myvars, ...}: {
  system.primaryUser = myvars.username;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${myvars.username}" = {
    home = "/Users/${myvars.username}";
  };
}
