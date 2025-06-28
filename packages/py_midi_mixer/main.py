import subprocess

def run_shell_command():
    # Prompt the user to enter a shell command
    command = input("Enter a shell command: ").strip()

    if not command:
        print("No command provided.")
        return

    try:
        # Execute the command while capturing its output and errors
        result = subprocess.run(
            command,
            shell=True,               # Caution: using shell=True can be a security hazard
            check=True,               # Raises CalledProcessError for non-zero exit codes
            stdout=subprocess.PIPE,   # Capture standard output
            stderr=subprocess.PIPE,   # Capture standard error
            text=True                 # Decode bytes to string (Python 3.7+)
        )
        
        # Print the command's output
        print("Output:")
        print(result.stdout)
        if result.stderr:
            print("Error Output:")
            print(result.stderr)
    
    except subprocess.CalledProcessError as e:
        print("Command failed with the following error:")
        print(e.stderr)

if __name__ == '__main__':
    run_shell_command()
