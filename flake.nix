{
  description = "Nix-Module";

    inputs = {
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    };

    outputs = { 
        self,
        nixpkgs, 
        nixpkgs-unstable 
    }: {

        nixosModules.essence = ./default.nix;
        nixosModules.default = self.nixosModules.essence;
        #packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
        #packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
        
    };
}
