{ pkgs, revision, ... }: 
let
    # Read current date in format <day_of_year>-<year>
    revision_with_date = builtins.readFile "${pkgs.runCommand "timestamp" { } 
        "echo -n ${revision}:`date +%j-%y` > $out"
    }";
in

{
    system.configurationRevision = "[${revision}]";
    system.nixos.label = "${revision_with_date}";
}
