{
  inputs = {
    # https://www.reddit.com/r/NixOS/comments/18d3ftz/comment/kcewc4b/
    #chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    #chaotic.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixos-hardware, nixpkgs, nixpkgs-unstable }: {
    # "nixos" is the hostname 
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        nixos-hardware = nixos-hardware;
      };
      modules = [
        ./configuration.nix
        # chaotic.nixosModules.default
      ];
    };
  };
}
