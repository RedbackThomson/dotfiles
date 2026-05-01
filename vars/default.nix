{lib}: {
  username = "nicholasthomson";
  userfullname = "Nicholas Thomson";
  useremail = "RedbackThomson@users.noreply.github.com";
  signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGpvYN2RMSthIzVHr5yoiBUBcRmkPpyIsWOiaYDyKkp";

  initialHashedPassword = "$7$GU..../....CHaBMHwimCbUYSwLs5dCH0$YnISUI6nU7PdNuyXeqUShkUhgXzP53sAR7jmYXeQ9H6";

  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8ocATMFmnCh7FrTAId910oIf/pmvMHtyFLg+GLDWWj"
  ];

  networking = import ./networking.nix {inherit lib;};
}
