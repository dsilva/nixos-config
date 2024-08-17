{
  inputs = {
    # https://www.reddit.com/r/NixOS/comments/18d3ftz/comment/kcewc4b/
    #chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    #chaotic.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/dsilva/nixos-unstable";

    # Importing the nixpkgs module from the howdy branch like this doesn't work:
    #   imports = [
    #     "${inputs.nixpkgs-howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
    #     "${inputs.nixpkgs-howdy}/nixos/modules/services/security/howdy/default.nix"
    #   ];
    # Somehow that builds, but Howdy doesn't run at password prompts (login screen or sudo).
    # So instead, merge the howdy branch into the nixos-unstable branch and use that as our nixpkgs.
    # https://github.com/NixOS/nixpkgs/pull/216245
    # To use nixpkgs branch nixos-unstable plus that unmerged PR:
    #   Fork nixpkgs to https://github.com/dsilva/nixpkgs
    #   git clone git@github.com:dsilva/nixpkgs.git
    #   cd nixpkgs
    #   gh pr checkout https://github.com/NixOS/nixpkgs/pull/216245
    #   git checkout nixos-unstable
    #   git checkout -b dsilva-nixos-unstable-howdy
    #   git merge howdy
    #   git mergetool
    #   git merge --continue
    # Then use the local git branch dsilva-nixos-unstable-howdy
    nixpkgs.url = "git+file:///home/daniel/src/nixpkgs?ref=dsilva-nixos-unstable-howdy";

    nixpkgs-howdy.url = "github:NixOS/nixpkgs/39edb2550421f88ff2a5c330c3471a2a9c596f91";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixos-hardware, nixpkgs, nixpkgs-howdy, nixpkgs-unstable }@inputs: {
    # "nixos" is the hostname 
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs nixos-hardware;
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./configuration.nix
        # chaotic.nixosModules.default
      ];
    };
  };
}
