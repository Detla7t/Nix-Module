{
    lib, 
    pkgs,
    enable ? true,
    packages ? lib.types.listOf lib.types.package,
    ...
}: (if (enable == true) then packages else [])