# 1usOS (Arch Linux) PKGBUILDs

This repository contains a collection of Arch Linux PKGBUILDs for 1usOS (ArchLinux-based), with support currently focused on AArch64 Platforms and SBCs, as well as a repository build system for building, mirroring and serving a pacman repository.

## Branches

To keep each branch clean and easy to maintain, each branch serve different purpose.

### Repository Build System
The following branches contains our repository build system.

- [main](https://github.com/1usOS/PKGBUILDs/tree/main) - This branch contains our repository build system and its configurations

### Platform-specific Repositories
The following branches contains PKGBUILDs of our pacman repositories.

- [rockchip](https://github.com/1usOS/PKGBUILDs/tree/rockchip) - This branch stores PKGBUILDs for packages related to the [Rockchip](https://rock-chips.com) Platform

- [asahi](https://github.com/1usOS/PKGBUILDs/tree/asahi) - This branch stores PKGBUILDs for packages related to the [Asahi Linux (Apple Silicon)](https://asahilinux.org) Platform

- [raspberrypi](https://github.com/1usOS/PKGBUILDs/tree/raspberrypi) - This branch stores PKGBUILDs for packages related to the [Raspberry Pi](https://www.raspberrypi.com) Platform

### Other Repositories
The following branches contains PKGBUILDs of our pacman repositories.

- [1usOS](https://github.com/1usOS/PKGBUILDs/tree/1usOS) - This branch stores PKGBUILDs for packages related to 1usOS Branding and 1usOS Experience

- [misc](https://github.com/1usOS/PKGBUILDs/tree/misc) - This branch stores PKGBUILDs of useful packages that isn't available on the Arch Linux core/extra repository, or need to be modified for non x86-64 platform.

- [multilib](https://github.com/1usOS/PKGBUILDs/tree/multilib) - This branch stores PKGBUILDs of 32-bit packages

## Using our Pacman Repository
**Disclaimer: This repository is experimental, some packages are unstable / not tested, DO NOT use this repository in production.**

- The repository is updated at **00:00 UTC daily**, as a result, there will be a few minutes downtime, so **avoid using this repository** at that time.

### Import signature key

#### Direct trust
As every package in this repo is signed with our PGP key, you must trust the repo before attempting to install any package.

import our signing key:
```
sudo pacman-key --recv-keys B669E3B56B3DC918
sudo pacman-key --lsign B669E3B56B3DC918
```

#### Bypass the signature
If you encounter gpg signature issue, you may bypass / disable the signature by adding `SigLevel = Never` to the repository configuration.

For example, edit your `/etc/pacman.conf` like this:
```
[misc]
SigLevel = Never
Server = https://github.com/1usOS/PKGBUILDs/releases/download/$arch
```

### Adding our repository to pacman

Replace the following part of `/etc/pacman.conf` using your favorite text editor:

```
#
# REPOSITORIES
#   - can be defined here or included from another file
#   - pacman will search repositories in the order defined here
#   - local/custom mirrors can be added here or in separate files
#   - repositories listed first will take precedence when packages
#     have identical names, regardless of version number
#   - URLs will have $repo replaced by the name of the current repo
#   - URLs will have $arch replaced by the name of the architecture
#
# Repository entries are of the format:
#       [repo-name]
#       Server = ServerName
#       Include = IncludePath
#
# The header [repo-name] is crucial - it must be present and
# uncommented to enable the repo.
#

# The testing repositories are disabled by default. To enable, uncomment the
# repo name header and Include lines. You can add preferred servers immediately
# after the header, and they will be used before the default mirrors.

#[1usOS]
#Server = https://github.com/1usOS/PKGBUILDs/releases/download/$arch

[misc]
Server = https://github.com/1usOS/PKGBUILDs/releases/download/$arch

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[rockchip]
Server = https://github.com/1usOS/PKGBUILDs/releases/download/$arch

#[multilib]
#Server = https://github.com/1usOS/PKGBUILDs/releases/download/$arch

# An example of a custom package repository.  See the pacman manpage for
# tips on creating your own repositories.
#[custom]
#SigLevel = Optional TrustAll
#Server = file:///home/custompkgs
```

## Building and Installing a package
If you just want to build / install a single package, there are many ways you can do that:
For example we want to build 	`mesa-panfrost-git`:

### Method 1: Using [ACU](https://github.com/kwankiu/acu)
Add the branch of this repository to ACU:
```
acu rem set rockchip https://github.com/kwankiu/PKGBUILDs --branch=rockchip
```
Fetch the repository:
```
acu update
```
Build and Install the package:
```
acu install mesa-panfrost-git
```
### Method 2: Using [AGR](https://github.com/hbiyik/agr)
Add the branch of this repository to AGR:
```
agr rem set rockchip https://github.com/kwankiu/PKGBUILDs.git --branch rockchip
```
Build and Install the package:
```
agr install mesa-panfrost-git
```

### Method 3: Using git and makepkg

Simply clone this repository (and switch to the branch of the target pkgbuild):
```
git clone https://github.com/kwankiu/PKGBUILDs.git -b rockchip
```
Now cd to the PKGBUILD's source of the cloned repository:
```
cd PKGBUILDs/mesa-panfrost-git
```
Now (make sure you are using a user account instead of root) we can build and install the package with :
```
makepkg -si
```
OR
build (without installing) the package:
```
makepkg -s
```

## Building packages and creating your own repository

We can build multiple packages in a clean, fast and efficient way using [ARB](https://github.com/7Ji/arb).

The main branch of this repository contains a simple build script (build.sh) that allows you to build a pacman repository easily from building the packages to signing the packages as well as adding them to a pacman db. Then you can simply upload the generated `repo` directory to a hosting provider or GitHub release.

### To begin, simply clone this repository:
```
git clone https://github.com/kwankiu/PKGBUILDs.git
```
Now cd to the cloned repository:
```
cd PKGBUILDs
```
### Add your signing key
Add your private key to gpg (or [create one](https://gist.github.com/elieux/fad9451bbfc4ddb5cde7) if you dont already have a key): 
Notes: Enter your passphrase whenever prompted to do so.
```
gpg --import myprivkey.asc
```

Import your signing key to pacman if you haven't:
```
sudo pacman-key --recv-keys YOURKEY
sudo pacman-key --lsign YOURKEY
```
### (Optional) Change the repository name:
Edit `build.sh`:
Replace
```
repo_name="experimental"
```
with your preferred repo name
```
repo_name="YOUR_REPO_NAME"
```
### (Tips) Building on x86_64 or if your packages output as .pkg.tar.zst instead of .pkg.tar.xz
Edit `build.sh`:
Uncomment the zst one and comment the xz one:
```
#repo-add -s -v -n ${repo_name}.db.tar.xz *.pkg.tar.xz
repo-add -s -v -n ${repo_name}.db.tar.xz *.pkg.tar.zst
```
### Start building your repository
You may also want to customize or use your own config yaml, ARB config yaml are documented [here](https://github.com/7Ji/arch_repo_builder#config).

Make sure you have permission to run the build script:
```
sudo chmod +x build.sh
```
To build all packages (from all yaml) at once:
```
./build.sh
```
OR
To build packages from a specified yaml (for example `rockchip.yaml`):
```
./build.sh rockchip
```

Once it is done, the repository are generated at the `repo` directory, you can simply upload everything from the generated directory to a hosting provider or GitHub release.
