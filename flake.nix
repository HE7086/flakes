{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dotfiles = {
    #   url = "https://github.com/HE7086/dotfiles";
    #   flake = false;
    #   type = "git";
    #   submodules = true;
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-unstable,
      sops-nix,
      disko,
      flake-utils,
      home-manager,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = with pkgs; [
            coreutils
            git
            just
            rsync
            curl
            openssh
            age
            sops
            jq
            mkpasswd
            ssh-to-age
          ];
        };
        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      nixosModules = import ./modules { inherit inputs; };
      nixosConfigurations = import ./hosts {
        inherit inputs self;
        rootPath = ./.;
      };
    };
}
