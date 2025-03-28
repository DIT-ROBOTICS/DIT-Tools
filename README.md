```
    ____  __________  ______            __    
   / __ \/  _/_  __/ /_  __/___  ____  / /____
  / / / // /  / /_____/ / / __ \/ __ \/ / ___/
 / /_/ // /  / /_____/ / / /_/ / /_/ / (__  ) 
/_____/___/ /_/     /_/  \____/\____/_/____/  
                                              
```

# DIT-Tools

This repository primarily maintains various development tools that the DIT Robotics team might use when developing robots, such as Groot, and strives to use containerized environments whenever possible.

## Groot2

The Groot2 tool is designed to simplify the development and debugging process for robotics projects. To use Groot2, you can set up an alias for convenience.

### Setting up the alias

Add the following line to your shell's RC file (e.g., `.bashrc`, `.zshrc`):

```bash
alias groot2=$(pwd)/DIT-Tools/Groot2/groot2
```

> **Note:** Replace `$(pwd)` with the actual path to your repository.

After adding the alias, reload your RC file or restart your terminal session:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Usage

Once the alias is set up, you can start Groot2 by simply typing:

```bash
groot2
```

This will automatically handle the following:
- Mounting all robot Groot workspaces in the current network environment using the Samba service provided by [DIT-Scripts](https://github.com/DIT-ROBOTICS/DIT-Scripts).
- Backing up the latest mounted directories for future reference.