{
    lib,
    config,
    name,
    ...
}: { 
    options = {
        enable = lib.mkEnableOption "service";
        activation = {
            enable =  lib.mkEnableOption "activation";
            runOnActivation = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = ''Weather to automatically run this service when nixos user activation is run.'';
            };
            name = lib.mkOption {
                type = lib.types.str;
                default = "${name}-activation-service";
                description = ''Name of the user's activation service'';
            };
            type = lib.mkOption {
                type = lib.types.str;
                default = "oneshot";
                description = ''type of service user's activation failure is.'';
            };
            preScript = lib.mkOption {
                type = lib.types.either lib.types.str lib.types.lines;
                default = ''
                    echo "Script Start: ''$(date)" > ~/last_activation_time.txt
                '';
                description = ''code to run before primary script runs'';
            };
            script = lib.mkOption {
                type = lib.types.either lib.types.str lib.types.lines;
                default = "";
                description = ''script to run when the user's activation service is started'';
            };
            postScript = lib.mkOption {
                type = lib.types.either lib.types.str lib.types.lines;
                default = ''
                    echo "Script Completed Successfully at: ''$(date)" >> ~/last_activation_time.txt
                    exit
                '';
                description = ''code to run after primary script runs'';
            };
            wantedBy = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ "default.target" ];
                description = ''targets used to activate the user's activation service'';
            };
        };
        failure = {
            enable =  lib.mkEnableOption "failure";
            name = lib.mkOption {
                type = lib.types.str;
                default = "${name}-failure-service";
                description = ''Name of the user's activation failure service'';
            };
            type = lib.mkOption {
                type = lib.types.str;
                default = "oneshot";
                description = ''type of service user's activation failure is.'';
            };
            script = lib.mkOption {
                type = lib.types.either lib.types.str lib.types.lines;
                default = ''
                    echo "'${config.essence.user."${name}".service.activation.name}.service' failed!" >> ~/last_activation_time.txt
                    exit
                '';
                description = ''script to run when the user's activation failure service is started'';
            };
        };
    };
}