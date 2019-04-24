#!/bin/sh

# This file may be needed if you want to build the source package for more fresh version of Ubuntu
# than the one you use. For instance, I can't build the package for Disco Dingo being on Bionic Beaver:
# debuild complains about unsatisfied dependencies. Docker can help here. Another place where this
# script can be suitable, is building Ubuntu source packages from non Ubuntu-based distros, like Arch Linux.

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
	clr_end=$'\e[0m'
else
	clr_red=''
	clr_end=''
fi

usage() {
	echo 'Usage:'
	echo '  publish-ppa-docker.sh [options]'
	echo
	echo 'options:'
	echo '  -h                      display this help message and exit'
	echo '  -d <distribution_tag>   publish for a given distribution'
	echo '     supported distributions:'
	echo '       xenial - Xenial Xerus (16.04.* LTS). Used as a default if -d is not provided'
	echo '       bionic - Bionic Beaver (18.04.* LTS)'
	echo '       cosmic - Cosmic Cuttlefish (18.10)'
	echo '       disco  - Disco Dingo (19.04)'
	echo '  -n                      do not upload to Launchpad'
}

checkDistribution() {
	test $1 = xenial -o $1 = bionic -o $1 = cosmic -o $1 = disco
}

# Xenial Xerus (the oldest supported distribution) is the default for this script if not told otherwise
distributionTag=xenial

upload=true

while getopts ":d:hn" opt; do
	case ${opt} in
		h)
			usage
			exit
			;;
		d)
			distributionTag=$OPTARG
			if ! checkDistribution $distributionTag
			then
				printf "${clr_red}ERROR: Unrecognized Ubuntu distribution '$distributionTag'.${clr_end}\n" 1>&2
				usage
				exit 1
			fi
			;;
		n)
			upload=false
			;;
		\?)
			printf "${clr_red}ERROR: Unrecognized option -$OPTARG.${clr_end}\n" 1>&2
			usage
			exit 1
			;;
		:)
			printf "${clr_red}ERROR: Option -$OPTARG requires an argument.${clr_end}\n" 1>&2
			usage
			exit 1
			;;
	esac
done

thisScriptDir=$(dirname "$0")
dockerTmpDir="$thisScriptDir/out/docker-tmp"

mkdir -p "$dockerTmpDir"
[ ! -d "$dockerTmpDir/gnupg" ] && cp -a ~/.gnupg/. "$dockerTmpDir/gnupg"

SERIES=${distributionTag} docker-compose build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) source_package
if [ ${upload} = true ]
then
	docker-compose run -e SERIES=${distributionTag} -e UPLOAD=true source_package
else
	docker-compose run -e SERIES=${distributionTag} source_package
fi
