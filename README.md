# dev configuration

## usage

```bash
# install if not already installed and configure
bash ./setup.sh powershell ohmyposh # or any other thing in src/setup/

# or run the install script directly
bash ./src/setup/ohmyposh.sh <install_dir> [--force]

# or just configure it (hopefully it's installed!)
bash ./configs/ohmyposh/config.sh
```

### ...but i'm on Windows!

two options to get bash on windows:

- Git for Windows installs bash (uses MinGW)
- Install MSYS2

to quickly use this repo on windows:

- download [win_bootstrap.ps1](https://raw.githubusercontent.com/gord0nf/software/refs/heads/main/win_bootstrap.ps1)
- run it to install Git for Windows
- clone this repo and use Git Bash

## organization

A `thing` is a software or some other tool. Each thing should have an install script at
`install/{THING}.sh`. A thing can also have config stuff in `config/{THING}/`, in which case
it must have a config script at `config/{THING}.sh` that links up anything in the directory.
Each install script has independent usage like `{THING}.sh <install_dir> [--force]` and each
config script has independent usage like `{THING}.sh [--force]`.
