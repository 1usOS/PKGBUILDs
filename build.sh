#!/bin/bash

################################################################
# Tools for formatting / styling

# Define terminal color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Echo with colors
colorecho() {
    color="$1"
    text="$2"
    echo -e "${color}${text}${NC}"
}
################################################################

colorecho "$BLUE" "Arch Repo Build Tool"
echo
system_arch=$(uname -m)
colorecho "$GREEN" "System is $system_arch"

mkdir -p build
cd build

if [ ! -f "arb" ] && [ ! $(command -v arb) ]; then
    if [ "$system_arch" == "aarch64" ] || [ "$system_arch" == "arm64" ] || [ "$system_arch" == "armv8" ]; then
        curl -LJO https://github.com/kwankiu/PKGBUILDs/releases/download/arb/arb-aarch64
        mv arb-aarch64 arb
        sudo chmod +x arb
    elif [ "$system_arch" == "x86_64" ]; then
        curl -LJO https://github.com/kwankiu/PKGBUILDs/releases/download/arb/arb-x86_64
        mv arb-x86_64 arb
        sudo chmod +x arb
    else
        colorecho "$RED" "Error: Unsupported System Arch. Exiting ..."
        exit 1
    fi
fi

if [ -n "$1" ]; then
    colorecho "$BLUE" "Building packages for $1 ..."
    sudo ./arb "../$1/build.yaml"
    if [ -n "$2" ]; then
        repo_name="$2"
    else
        repo_name="$1"
    fi
else
    colorecho "$RED" "Error: You must specify a repository to build"
    exit 1
fi

colorecho "$BLUE" "Copying new packages to repository ($repo_name) ..."
cd ../
mkdir -p repo/$repo_name
cp -L build/pkgs/updated/* repo/$repo_name
cd repo/$repo_name

# Sign pkg
colorecho "$BLUE" "Signing new packages ..."

pkg=($(ls | grep .pkg.tar | grep -v .sig))
for ((i = 0; i < ${#pkg[@]}; i++)); do
    if [ -f "${pkg[i]}.sig" ]; then
        echo "${pkg[i]} already signed, skipping ..."
    else
        echo "Signing ${pkg[i]} ..."
        if [ -z "$gpgpass" ]; then
            gpg --detach-sign --no-armor ${pkg[i]}
        else
            gpg --batch --passphrase "$gpgpass" --detach-sign --no-armor ${pkg[i]}
        fi
    fi
done

#repo-add -s -v -n ${repo_name}.db.tar.xz *.pkg.tar.xz
#repo-add -s -v -n ${repo_name}.db.tar.xz *.pkg.tar.zst
sudo rm -rf *db*.old *db*.old.*
