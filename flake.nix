{
  description = "Nix-Module";

    inputs = {
        #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    };

    outputs = { 
        self,
        nixpkgs, 
        #nixpkgs-unstable 
    }: {

        nixosModules.essence = ./default.nix;
        nixosModules.default = self.nixosModules.essence;
        nixosModules.lib = ./modules/lib/local_lib.nix;
    };
}
