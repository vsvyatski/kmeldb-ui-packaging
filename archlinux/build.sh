#!/bin/sh

case "$BASH" in
	*/bash)
		isBash=true
		;;
	*)
		isBash=false
		;;
esac

# Let's define some colors
if [ ${isBash} = true ]
then
    clr_red=$'\e[1;31m'
    clr_yellow=$'\e[1;33m'
    clr_end=$'\e[0m'
else
    clr_red=''
    clr_yellow=''
    clr_end=''
fi

thisScriptDir=$(dirname "$0")
outDir="$thisScriptDir/out"
if [ ! -d "$outDir" ]
then
	mkdir "$outDir"
else
	rm -rf "$outDir/"*
fi

if [ ! -f /usr/bin/makepkg ]
then
    printf "${clr_yellow}WARNING: makepkg is missing. Pacman is most likely not the package manager of this system. The build will be delegated to Docker.${clr_end}\n"
    cd "$thisScriptDir"
    docker-compose build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) pacman_package
    docker-compose run pacman_package
    exit 0
fi

packageMaintainer="Vladimir Svyatski <vsvyatski@yandex.ru>"

cd "$thisScriptDir"
makepkg -f PACKAGER="$packageMaintainer" BUILDDIR="$outDir" SRCDEST="$outDir" PKGDEST="$outDir"
cd -
