{
  description = "A NixOS configuration for https://github.com/redbackthomson's machines";

  outputs = inputs: import ./outputs inputs;

  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.flox.dev"
      "https://yazi.cachix.org"
      "https://claude-code.cachix.org"
    ];
    extra-trusted-public-keys = [
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-ryan4yin.url = "github:ryan4yin/nur-packages";
    _1password-shell.url = "github:1Password/shell-plugins";
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-custom-icons.url = "github:ryanccn/nix-darwin-custom-icons";
    flox.url = "github:flox/flox/latest";
    yazi.url = "github:sxyazi/yazi";
    claude-code.url = "github:sadjow/claude-code-nix";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix/db5637d10f797bb251b94ef9040b237f4702cde3";
    mysecrets = {
      url = "github:redbackthomson/dotfiles-secrets";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
