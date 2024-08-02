{
  description = "User environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        system = "x86_64-linux";
      };
    in
   {

    packages.x86_64-linux.default = import ./default.nix {
      inherit pkgs;
    };

  };
}
