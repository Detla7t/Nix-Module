{ 
    lib, 
    pkgs,
    ... 
}: 
rec {
    
        Copy_file = FILE: OUTPUT_DIRECTORY: 
            ''
                echo "Starting Copy_file on: '${OUTPUT_DIRECTORY}'"
                if [ ! -e "${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}" ]; then 
                    cp ${FILE.file} ${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}
                    chmod +rw ${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}
                fi
            '';

        Copy_Folder = SOURCE_FOLDER: OUTPUT_DIRECTORY:
        ''
            echo "Starting Copy_Folder on: '${OUTPUT_DIRECTORY}'"
            # Change to the source directory
            cd "${SOURCE_FOLDER}"

            # Find each file (recursively) and create a symlink in the destination.
            find . -type f | while read -r file; do
                # Remove any leading "./" from the file path
                rel="''${file#./}"       
                # Create the corresponding directory in the destination if it doesn't exist
                mkdir -p "${OUTPUT_DIRECTORY}/$(dirname "$rel")"
                
                # Copy Out checking
                if [ ! -e "${OUTPUT_DIRECTORY}/$rel" ]; then 
                    cp "${SOURCE_FOLDER}/$rel" "${OUTPUT_DIRECTORY}/$rel"
                    chmod +rw "${OUTPUT_DIRECTORY}/$rel"
                fi
            done
        '';

        File_Lazy_Build = FILENAME: FOLDER: FILE: {
            folder = FOLDER;
            filename = FILENAME;
            file = pkgs.writeTextFile {name=FILENAME; text=FILE;};
        };

        File_Builder = FILENAME: RELATIVE_FOLDER: LOCAL_FOLDER: {
            folder = RELATIVE_FOLDER;
            filename = FILENAME;
            file = pkgs.writeText FILENAME (builtins.readFile "${LOCAL_FOLDER}/${RELATIVE_FOLDER}/${FILENAME}");
        };

        Force_Copy = FILE: OUTPUT_DIRECTORY: 
            ''
                echo "Starting Force_Copy on: '${OUTPUT_DIRECTORY}'"
                cp ${FILE.file} ${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}
                chmod +rw ${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}
            '';

        Force_Copy_Folder = SOURCE_FOLDER: OUTPUT_DIRECTORY:
        ''
            echo "Starting Force_Copy_Folder on: '${OUTPUT_DIRECTORY}'"
            # Change to the source directory
            cd "${SOURCE_FOLDER}"

            # Find each file (recursively) and create a symlink in the destination.
            find . -type f | while read -r file; do
                # Remove any leading "./" from the file path
                rel="''${file#./}"       
                # Create the corresponding directory in the destination if it doesn't exist
                mkdir -p "${OUTPUT_DIRECTORY}/$(dirname "$rel")"
                
                # Copy Out checking
                if [ -e "${OUTPUT_DIRECTORY}/$rel" ]; then 
                    mv "${OUTPUT_DIRECTORY}/$rel" "${OUTPUT_DIRECTORY}/$rel.backup"
                    cp "${SOURCE_FOLDER}/$rel" "${OUTPUT_DIRECTORY}/$rel"
                    chmod +rw "${OUTPUT_DIRECTORY}/$rel"
                else
                    cp "${SOURCE_FOLDER}/$rel" "${OUTPUT_DIRECTORY}/$rel"
                    chmod +rw "${OUTPUT_DIRECTORY}/$rel"
                fi
            done
        '';

        Force_Link = FILE: OUTPUT_DIRECTORY: 
            ''
                echo "Starting Force_Link on: '${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}'"
                if [ -e "${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}" ]; then 
                    ln -nsf "${FILE.file}" "${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}"
                else
                    ln -s "${FILE.file}" "${OUTPUT_DIRECTORY}/${FILE.folder}/${FILE.filename}"
                fi
            '';

        Folder_link = FOLDER: OUTPUT_DIRECTORY:
            ''
                echo "Starting Folder_link on: '${OUTPUT_DIRECTORY}'"
                if [ ! -d "${OUTPUT_DIRECTORY}" ]; then 
                    mkdir -p "${OUTPUT_DIRECTORY}"
                    ln -s "${FOLDER}"/* "${OUTPUT_DIRECTORY}"
                else
                    ln -nsf "${FOLDER}"/* "${OUTPUT_DIRECTORY}"
                fi
            ''
        ;

        /*
        ImportListMapper: example usage
            import_home_and_remote = { inherit config; inherit lib; inherit pkgs; inherit home_directory; inherit remote_directory; };
            file_list_home_only = [
                ../programs/fastfetch.nix 
                ../programs/keeweb.nix 
                ../programs/kitty.nix 
                ../programs/micro.nix 
                ../programs/qbittorrent.nix 
                ../programs/rclone.nix 
                ../programs/reaper.nix 
                ../programs/starship.nix 
                ../programs/vscode.nix 
                ../programs/zsh.nix 
            ];
            imports = [ ] 
                ++ ImportListMapper file_list_home_and_remote import_home_and_remote;

        In this example provided we have an attribute set of various imports that need to be given to each of the imports in the list. then
        we map each to a list and append that list to imports to each item looks like this when mapped. or atleast is similar

        (import ../programs/fastfetch.nix {inherit config; inherit lib; inherit pkgs; inherit home_directory; inherit remote_directory;})
        
        */
        ImportListMapper = file_import_list: args: map (file: import file args) file_import_list;

        /* 
            This function reads the moves to the SOURCE_FOLDER then checks if its reading a file. if it is reading a file it makes the 
            corrisponding directory in the OUTPUT_DIRECTORY location then check if that file has a link in the output. if not it makes
            one. otherwise
        */
        link_files_build_directories = SOURCE_FOLDER: OUTPUT_DIRECTORY:
        ''
            echo "Starting link_files_build_directories on: '${OUTPUT_DIRECTORY}'"
            # Change to the source directory
            cd "${SOURCE_FOLDER}"

            # Find each file (recursively) and create a symlink in the destination.
            find . -type f | while read -r file; do
                # Remove any leading "./" from the file path
                rel="''${file#./}"       
                # Create the corresponding directory in the destination if it doesn't exist
                mkdir -p "${OUTPUT_DIRECTORY}/$(dirname "$rel")"
                
                # Create the symbolic link
                if [ -L "${OUTPUT_DIRECTORY}/$rel" ]; then 
                    ln -nsf "${SOURCE_FOLDER}/$rel" "${OUTPUT_DIRECTORY}/$rel"
                elif [ -e "${OUTPUT_DIRECTORY}/$rel" ]; then
                    mv "${OUTPUT_DIRECTORY}/$rel" "${OUTPUT_DIRECTORY}/$rel.backup"
                    ln -nsf "${SOURCE_FOLDER}/$rel" "${OUTPUT_DIRECTORY}/$rel"
                else
                    ln -s "${SOURCE_FOLDER}/$rel" "${OUTPUT_DIRECTORY}/$rel"
                fi

            done
        '';

        Link_file = FILE: OUTPUT: 
            ''
                echo "Starting Link_file on: '${OUTPUT}'"
                if [ ! -e "${OUTPUT}" ]; then 
                    ln -s ${FILE} ${OUTPUT}
                fi
            '';

        mkdir = folder:
            ''mkdir -p "${folder}"'';

        map_file_list = File_list: function:
            (map (x: function x.file x.location) File_list);

        generic_map_file_list = File_list: function:
            (map (x: function (builtins.elemAt x 0) (builtins.elemAt x 1)) File_list);
            
        Script_File_Builder = FILENAME: RELATIVE_FOLDER: LOCAL_FOLDER: {
            folder = RELATIVE_FOLDER;
            filename = FILENAME;
            file = pkgs.writeTextFile {name=FILENAME; text=builtins.readFile "${LOCAL_FOLDER}/${RELATIVE_FOLDER}/${FILENAME}"; executable = true;};
        };

        Simple_Force_Link = INPUT: OUTPUT: 
            ''
                echo "Starting Simple_Force_Link on: ${OUTPUT}"
                if [ -L "${OUTPUT}" ]; then 
                    ln -nsf "${INPUT}" "${OUTPUT}"
                elif [ -e "${OUTPUT}" ]; then 
                    mv "${OUTPUT}" "${OUTPUT}.backup"
                    ln -s "${INPUT}" "${OUTPUT}"
                else
                    ln -s "${INPUT}" "${OUTPUT}"
                fi
            '';

        Simple_Folder_link = INPUT: OUTPUT:
            ''
                echo "Starting Simple_Folder_link: ${OUTPUT}"
                if [ ! -e "${OUTPUT}" ]; then
                    mkdir -p "${OUTPUT}"
                    ln -s "${INPUT}" "${OUTPUT}"
                elif [ -L "" ]
            '';

        Simple_Copy_file = INPUT: OUTPUT: 
            ''
                echo "Starting Simple_Copy_file on: ${OUTPUT}"
                if [ ! -e "${OUTPUT}" ]; then 
                    cp ${INPUT} ${OUTPUT}
                    chmod +rw ${OUTPUT}
                fi
            '';

        Write_file_to_store = FILENAME: FILE_LOCATION: pkgs.writeText FILENAME (builtins.readFile FILE_LOCATION);
        writeHomeFile = {
            destination,
            text,               # or file, folder
            link ? true,        # Make a symbloic link
            isFolder ? false,   # Weather the text input is a folder instead of a file or raw text
            copy ? false,       # Copy text input weather its a folder, file, or raw text
            make ? false,       # This Toggle should act like a force for either link or copy and should rename the previous to .bak
        }: builtins.concatStringsSep "\n" [ 
            # Folder Operations
            ( if (link == false && isFolder == true && copy == false && make == true)  then mkdir               text destination else "" )
            ( if (link == false && isFolder == true && copy == true && make == false)  then Copy_Folder         text destination else "" )
            ( if (link == true && isFolder == true && copy == false && make == true)   then link_files_build_directories    text destination else "" )
            ( if (link == true && isFolder == true && copy == false && make == false)  then Folder_link         text destination else "" )
            ( if (link == true && isFolder == true && copy == true && make == true)    then Force_Copy_Folder   text destination else "" ) 
            # File Operations
            ( if (link == true && isFolder == false && copy == false && make == false) then Simple_Force_Link   text destination else "" )
            ( if (link == false && isFolder == false && copy == true && make == false) then Simple_Copy_file    text destination else "" )
            ( if (link == false && isFolder == false && copy == true && make == true)  then Force_Copy_Folder   text destination else "" )
        ];
        writeHomeFileList = {
            #destination,
            list,
            #text,               # or file, folder
            link ? true,        # Make a symbloic link
            isFolder ? false,   # Weather the text input is a folder instead of a file or raw text
            copy ? false,       # Copy text input weather its a folder, file, or raw text
            make ? false,       # This Toggle should act like a force for either link or copy and should rename the previous to .bak
        }: builtins.concatStringsSep "\n" [ 
            # Folder Operations
            ( if (link == false && isFolder == true && copy == false && make == true) then 
                builtins.concatStringsSep "\n" (map (x: mkdir x) list) 
            else "" )
            ( if (link == false && isFolder == true && copy == true && make == false) then 
                (generic_map_file_list list Copy_Folder)
            else "" )
            ( if (link == true && isFolder == true && copy == false && make == true) then 
                (generic_map_file_list list link_files_build_directories)
            else "" )
            ( if (link == true && isFolder == true && copy == false && make == false) then 
                (generic_map_file_list list Folder_link)
            else "" )
            ( if (link == true && isFolder == true && copy == true && make == true) then 
                (generic_map_file_list list Force_Copy_Folder)
            else "" ) 
            # File Operations
            ( if (link == true && isFolder == false && copy == false && make == false) then 
                (generic_map_file_list list Simple_Force_Link)
            else "" )
            ( if (link == false && isFolder == false && copy == true && make == false) then 
                (generic_map_file_list list Simple_Copy_file)
            else "" )
            ( if (link == false && isFolder == false && copy == true && make == true) then 
                (generic_map_file_list list Force_Copy_Folder)
            else "" )
        ];
}