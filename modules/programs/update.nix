{
  config,
  lib,
  pkgs,
  ...
}: let
  #Update_script = pkgs.writeShellScriptBin "updater" ''
  Update_script = pkgs.writeShellApplication {
    name = "update";
    runtimeInputs = with pkgs; [
        git
        nh
    ];
    text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    FLAKE_DIR="${config.programs.nh.flake}"
    FLAKE_MAX_JOBS="''${FLAKE_MAX_JOBS:-4}"
    SHOW_UPDATER_WARNINGS="''${SHOW_UPDATER_WARNINGS:-1}"

    # Detect available commands
    HAS_FLATPAK=0
    HAS_GIT=0
    HAS_NH=0
    HAS_NIX=0
    HAS_NIXOS_REBUILD=0
    command -v flatpak >/dev/null 2>&1 && HAS_FLATPAK=1
    command -v git >/dev/null 2>&1 && HAS_GIT=1
    command -v nh >/dev/null 2>&1 && HAS_NH=1
    command -v nix >/dev/null 2>&1 && HAS_NIX=1
    command -v nixos-rebuild >/dev/null 2>&1 && HAS_NIXOS_REBUILD=1

    # Default commands
    NH_DRY_COMMAND=''${NH_DRY_COMMAND:-'nh os switch -H "'$(hostname)'" -n'}
    NH_BUILD_COMMAND=''${NH_BUILD_COMMAND:-'nh os switch -H "'$(hostname)'"'}
    NH_UPGRADE_COMMAND=''${NH_UPGRADE_COMMAND:-'nh os switch -H "'$(hostname)'" -u'}
    NIX_DRY_COMMAND=''${NIX_DRY_COMMAND:-'nixos-rebuild dry-build --flake .#'$(hostname)'''}
    NIX_BUILD_COMMAND=''${NIX_BUILD_COMMAND:-'nixos-rebuild switch --flake .#'$(hostname)'''}
    NIX_UPGRADE_COMMAND=''${NIX_UPGRADE_COMMAND:-'nix flake lock'}

    # Colors
    CSI="\033["
    RESET="''${CSI}0m"
    GREEN="''${CSI}32m"
    YELLOW="''${CSI}33m"
    RED="''${CSI}31m"
    BOLD="''${CSI}1m"

    # Symbols
    SYM_OK="✔"
    SYM_NO="✖"
    SYM_INFO="●"

    usage() {
        echo -e "''${BOLD}Usage:''${RESET} update [all|flake|flatpak|upgrade|help] [-- <args>] \n"
        echo -e "''${BOLD}Note:''${RESET} If you're using ''${BOLD}nh''${RESET} you can update with just \"update upgrade\"\nif your using stock ''${BOLD}nix''${RESET} update by running \"update upgrade\" then \"update all\" \n"
        echo -e "''${BOLD}Available tools:''${RESET}"
        if [ "$HAS_GIT" -eq 1 ]; then
            echo -e "  ''${GREEN}''${SYM_OK}''${RESET} git"
        else
            echo -e "  ''${RED}''${SYM_NO}''${RESET} git"
        fi
        if [ "$HAS_NH" -eq 1 ]; then
            echo -e "  ''${GREEN}''${SYM_OK}''${RESET} nh"
        else
            echo -e "  ''${RED}''${SYM_NO}''${RESET} nh"
        fi
        if [ "$HAS_FLATPAK" -eq 1 ]; then
            echo -e "  ''${GREEN}''${SYM_OK}''${RESET} flatpak"
        else
            echo -e "  ''${RED}''${SYM_NO}''${RESET} flatpak"
        fi
        echo
        echo -e "''${BOLD}Commands:''${RESET}"
        cat <<EOF
    help        Show this message
    all         Update flatpaks then the flake (flake run includes git checks, dry-run, optional push, real build)
    flatpak     Run 'flatpak update' only. No git changes.
    flake       Run flake update: verify git clean, dry-run build, optional push, real build.
    upgrade     Run 'nix flake update' in the repo root, commit flake.lock with default message and optionally push.

    Pass extra args to the internal 'nh' calls by using the '--' separator.
    Examples:
    update flake -- -j 2
    update all -- -j 2 -v
        
    EOF
    }

    _warn() {
        local msg="$1"
        if [ "''${SHOW_UPDATER_WARNINGS:-1}" != "0" ]; then
            echo -e "''${YELLOW}Warning:''${RESET} ''${msg}"
        fi
    }

    # Capture passthrough args (anything after the subcommand)
    PASSTHRU_ARGS=()
    if [ "$#" -ge 2 ]; then
        PASSTHRU_ARGS=("''${@:2}")
        if [ "''${PASSTHRU_ARGS[0]:-}" = "--" ]; then
            PASSTHRU_ARGS=("''${PASSTHRU_ARGS[@]:1}")
        fi
    fi

    yes_no_question() {
        local message="$1"
        local default_option="$2"
        local command_to_run="$3"
        local alternate_command="$4"

        while true; do
            if [[ $default_option == "yes" ]]; then
                read -r -p "$message [Y/n]: " answer
            else
                read -r -p "$message [y/N]: " answer
            fi

            case "''${answer}" in
                [Yy]* )
                    if [[ $default_option == "yes" ]]; then
                        [[ -n $command_to_run ]] && eval "$command_to_run"
                        return 1
                    else
                        [[ -n $alternate_command ]] && eval "$alternate_command"
                        return 1
                    fi
                    ;;
                [Nn]* )
                    if [[ $default_option == "no" ]]; then
                        [[ -n $command_to_run ]] && eval "$command_to_run"
                        return 0
                    else
                        [[ -n $alternate_command ]] && eval "$alternate_command"
                        return 0
                    fi
                    ;;
                [Ee][Xx][Ii][Tt] ) exit ;;
                "" )
                    if [[ $default_option == "yes" ]]; then
                        [[ -n $command_to_run ]] && eval "$command_to_run"
                        return 1
                    elif [[ $default_option == "no" ]]; then
                        [[ -n $command_to_run ]] && eval "$command_to_run"
                        return 0
                    fi
                    ;;
                * )
                    echo "Invalid choice. Please enter 'Yes', 'No' or 'Exit'."
                    ;;
            esac
        done
    }

    update_flatpak() {
        if [ "$HAS_FLATPAK" -eq 0 ]; then
            _warn "flatpak not found. 'update flatpak' will fail."
            echo "Skipping flatpak update"
            return 1
        fi
        echo "==> Running flatpak update"
        if ! flatpak update; then
            echo "flatpak update failed"
            return 1
        fi
        echo "flatpak update complete"
        return 0
    }

    # Git helpers
    check_repo_clean() {
        # Run in repo root. Return 0 if clean or unknown, 1 if dirty.
        if [ "$HAS_GIT" -eq 0 ]; then
            _warn "git is not available. Skipping repository cleanliness check."
            return 0
        fi
        if [ -n "$(git status --porcelain -- 'flake.lock')" ]; then
            echo "flake.lock file has uncommited changes would you like to auto commit"
            if $(yes_no_question "Push local commits to remote?" "yes" "true" "false"); then
                git add flake.lock
                commit_msg="Updated flake.lock inputs."
                if ! git commit -m "$commit_msg"; then
                    echo "git commit failed"
                    return 1
                fi
                echo "Committed flake.lock with message: $commit_msg"
            fi
        fi
        if [ -n "$(git status --porcelain)" ]; then
            echo "Repository has uncommitted changes:"
            git status --short
            return 1
        fi
        return 0
    }

    commit_flake_lock() {
        # If flake.lock changed or is untracked, commit it
        if [ "$HAS_GIT" -eq 0 ]; then
            _warn "git is not available. skipping flake.lock git management."
            return 0
        fi
        if [ -n "$(git status --porcelain -- 'flake.lock')" ]; then
            git add flake.lock
            commit_msg="Updated flake.lock"
            if ! git commit -m "$commit_msg"; then
                echo "git commit failed"
                return 1
            fi
            echo "Committed flake.lock with message: $commit_msg"

            if $(yes_no_question "Push local commits to remote?" "yes" "true" "false"); then
                if [ "$HAS_GIT" -eq 1 ]; then
                    if ! push_commits; then
                        echo "git push failed"
                        return 1
                    fi
                    echo "Push complete."
                else
                    _warn "git not available. Cannot push committed flake.lock."
                fi
            else
                echo "Not pushing commits."
            fi
        else
            echo "flake.lock unchanged; no commit needed."
        fi
    }

    push_commits() {
        # Push current branch to upstream or set upstream if needed.
        # Returns 0 on success, non-zero on failure.
        if [ "$HAS_GIT" -eq 0 ]; then
            _warn "git not available. Cannot push commits."
            return 1
        fi

        local branch
        branch=$(git rev-parse --abbrev-ref HEAD)

        if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
            if ! git push; then
                echo "git push failed"
                return 1
            fi
        else
            if ! git push --set-upstream origin "$branch"; then
                echo "git push --set-upstream failed"
                return 1
            fi
        fi
        return 0
    }

    # Helper to run nh with optional extra args or FLAKE_MAX_JOBS
    _run_cmd() {
        local base_cmd=("$@")
        local cmd_args=()
        if [ "''${#PASSTHRU_ARGS[@]}" -gt 0 ]; then
            cmd_args=("''${PASSTHRU_ARGS[@]}")
        elif [ -n "$FLAKE_MAX_JOBS" ]; then
            cmd_args=("-j" "$FLAKE_MAX_JOBS")
        fi

        if [ "''${#cmd_args[@]}" -gt 0 ]; then
            "''${base_cmd[@]}" "''${cmd_args[@]}"
        else
            "''${base_cmd[@]}"
        fi
    }
    # Helper to run nh with optional extra args or FLAKE_MAX_JOBS
    _run_nh() {
        local base_cmd=("$@")
        local nh_args=()
        if [ "''${#PASSTHRU_ARGS[@]}" -gt 0 ]; then
            nh_args=("''${PASSTHRU_ARGS[@]}")
        elif [ -n "$FLAKE_MAX_JOBS" ]; then
            nh_args=("-j" "$FLAKE_MAX_JOBS")
        fi

        if [ "''${#nh_args[@]}" -gt 0 ]; then
            "''${base_cmd[@]}" -- "''${nh_args[@]}"
        else
            "''${base_cmd[@]}"
        fi
    }

    update_flake() {
        local branch unpushed
        local push_yes=0
        git_push() {
            # If user wants to push and git exists, attempt push
            if [ "$push_yes" -eq 1 ]; then
                echo "Pushing commits to remote..."
                if ! push_commits; then
                    return 1
                fi
                echo "Push complete."
            fi
            return 0
        }
        git_management() {
            # Use the dedicated git check
            if ! check_repo_clean; then
                echo "Flake path is dirty! Please commit changes before continuing."
                return 1
            fi

            # Determine unpushed commits if git is available
            unpushed=0
            branch=$(git rev-parse --abbrev-ref HEAD)
            if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
                unpushed=$(git rev-list --count @{u}..HEAD)
            else
                unpushed=$(git rev-list --count HEAD)
            fi

            
            if [ "$unpushed" -gt 0 ]; then
                echo "Local branch '$branch' has $unpushed unpushed commit(s)."
                if $(yes_no_question "Push local commits to remote?" "yes" "true" "false"); then
                    push_yes=1
                else
                    push_yes=0
                fi
            fi
        }
        nh_path() {
            echo "Running dry-run to check for errors"
            if ! _run_nh $NH_DRY_COMMAND; then
                echo "Dry-run build failed. Aborting without pushing."
                return 1
            fi
            echo "Dry-run build succeeded."

            git_push

            echo "Running final build to finish update."
            if ! _run_nh $NH_BUILD_COMMAND; then
                echo "Real build failed."
                return 1
            fi
            echo "Real build succeeded."
            return 0
        }
        stock_nix_path() {
            echo "Running dry-run to check for errors"
            if ! _run_cmd $NIX_DRY_COMMAND; then
                echo "Dry-run build failed. Aborting without pushing."
                return 1
            fi
            echo "Dry-run build succeeded."

            git_push

            echo "Running final build to finish update."
            if ! _run_cmd $NIX_BUILD_COMMAND; then
                echo "Real build failed."
                return 1
            fi
            echo "Real build succeeded."
            return 0
        }
        main() {
            echo "==> Running flake update at: $FLAKE_DIR"
            if [ ! -d "$FLAKE_DIR" ]; then
                echo "Flake path does not exist: $FLAKE_DIR"
                return 1
            fi
            
            cd "$FLAKE_DIR" || return 1

            if [ "$HAS_GIT" -eq 1 ]; then
                git_management
            else
                _warn "git is not available. Skipping all git checks."
            fi
            if [ "$HAS_NH" -eq 1 ]; then
                nh_path
            else 
                _warn "nh is not available."
                stock_nix_path
            fi
        }
        if [[ "$HAS_NIXOS_REBUILD" -eq 0 && "$HAS_NH" -eq 0 ]]; then
            _warn "nixos-rebuild and nh commands are not available. Unable to perform an update."
            return 1
        fi
        main
    }

    upgrade_flake_lock() {
        commit_flake_lock() {
            # If flake.lock changed or is untracked, commit it
            if [ -n "$(git status --porcelain -- 'flake.lock')" ]; then
                git add flake.lock
                commit_msg="Updated flake.lock inputs."
                if ! git commit -m "$commit_msg"; then
                    echo "git commit failed"
                    return 1
                fi
                echo "Committed flake.lock with message: $commit_msg"

                if $(yes_no_question "Push local commits to remote?" "yes" "true" "false"); then
                    if [ "$HAS_GIT" -eq 1 ]; then
                        if ! push_commits; then
                            echo "git push failed"
                            return 1
                        fi
                        echo "Push complete."
                    else
                        _warn "git not available. Cannot push committed flake.lock."
                    fi
                else
                    echo "Not pushing commits."
                fi
            else
                echo "flake.lock unchanged; no commit needed."
            fi
        }
        git_management() {
            # Warn if repository has uncommitted changes
            if [ -n "$(git status --porcelain)" ]; then
                echo "Repository has uncommitted changes:"
                git status --short
                yes_no_question "Repository is dirty. Continue with 'nix flake update' anyway?" "no" "return 1" "return 0"
            fi
        }
        nh_path () {
            echo "Running 'nh update command'..."
            if ! $($NH_UPGRADE_COMMAND); then
                echo "flake update failed"
                return 1
            fi
        }
        stock_nix_path() {
            echo "Running 'nix flake update command'..."
            if ! $($NIX_UPGRADE_COMMAND); then
                echo "flake update failed"
                return 1
            fi
        }
        main() {
            echo "==> Upgrading flake inputs at: $FLAKE_DIR"
            if [ ! -d "$FLAKE_DIR" ]; then
                echo "Flake path does not exist: $FLAKE_DIR"
                return 1
            fi

            cd "$FLAKE_DIR" || return 1

            if [ "$HAS_GIT" -eq 1 ]; then
                git_management
            else
                _warn "git is not available. Skipping all git checks."
            fi
            if [ "$HAS_NH" -eq 1 ]; then
                nh_path
            else 
                _warn "nh is not available."
                stock_nix_path
            fi
            if [ "$HAS_GIT" -eq 1 ]; then
                commit_flake_lock
            fi
        }
        if [[ "$HAS_NH" -eq 0 && "$HAS_NIX" -eq 0 ]]; then
            _warn "nix and nh commands are not available. Unable to perform an upgrade."
            return 1
        fi
        main;
    }

    case "''${1:-}" in
        ""|help|-h|--help)
            usage
            exit 0
            ;;
        all)
            update_flatpak || exit 1
            update_flake || exit 1
            ;;
        flatpak)
            update_flatpak || exit 1
            ;;
        flake)
            update_flake || exit 1
            ;;
        upgrade)
            upgrade_flake_lock || exit 1
            ;;
        *)
            echo "Unknown subcommand: ''${1:-}"
            usage
            exit 2
            ;;
    esac
    '';
  }; 
in {
  options = {
        # option declarations
        essence = {
            updater = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = ''
                        Enables the system updater that uses Nix Helper as the backend
                    '';
                };
                max-jobs = lib.mkOption {
                    type = lib.types.str;
                    default = "4";
                    description = ''
                        Sets the Max number of jobs used by default when rebuilding using the all or flake update subcommands.
                    '';
                };
            };
        };
    };
  config = let 
        cfg = config.essence.updater;
  in {
        environment = lib.mkIf (cfg.enable == true) {
            systemPackages = [
                Update_script
            ];
            variables = { 
                FLAKE_MAX_JOBS = cfg.max-jobs; 
            };
        };
        programs = lib.mkIf (cfg.enable == true) {
            nh.enable = true;
            #zsh.shellAliases = {
            #    update = "${lib.getExe Update_script}";
            #};
        };
  };
}
