{
    description = "A python program";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    };

    #OPEN THIS FLAKE WITH `nix develop`

    outputs = { self, nixpkgs, ... }:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; config.allowUnfree = true; hostPlatform.config = "${system}";};
        in
        {
            devShells.${system}.default = pkgs.mkShell {
                venvDir = ".venv";
                packages = with pkgs; [ python313 ] ++
                    (with pkgs.python313Packages; [
                        pip
                        venvShellHook
                    ]);
                shellHook = ''
                    echo "I'm a happy shell :)"
                '';
            };
            packages.x86_64-linux.default = self.devShells.${system}.default;
        };
}