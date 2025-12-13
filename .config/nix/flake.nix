{
  description = "A NixOS configuration for https://github.com/redbackthomson's machines";

  outputs = inputs: import ./outputs inputs;

  nixConfig = {
    extra-trusted-substituters = ["https://cache.flox.dev"];
    extra-trusted-public-keys = ["flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="];
  };

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-25.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    _1password-shell = {
      url = "github:1Password/shell-plugins";
    };
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-custom-icons = {
      url = "github:ryanccn/nix-darwin-custom-icons";
    };
    flox = {
      url = "github:flox/flox/latest";
    };
  };
}
