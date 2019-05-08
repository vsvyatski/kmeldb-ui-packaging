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
	clr_end=$'\e[0m'
else
	clr_red=''
	clr_end=''
fi

usage() {
	echo 'Usage:'
	echo '  publish-ppa.sh [options]'
	echo
	echo 'options:'
	echo '  -h                 display this help message and exit'
	echo '  -d <series_tag>    publish for a given series'
	echo '     supported series:'
	echo '       xenial - Xenial Xerus (16.04.* LTS). Used as a default if -d is not provided'
	echo '       bionic - Bionic Beaver (18.04.* LTS)'
	echo '       cosmic - Cosmic Cuttlefish (18.10)'
	echo '       disco  - Disco Dingo (19.04)'
	echo '  -n                 do not upload to Launchpad'
}

checkSeries() {
	test $1 = xenial -o $1 = bionic -o $1 = cosmic -o $1 = disco
}

# Xenial Xerus (the oldest supported series) is the default for this script if not told otherwise
seriesTag=xenial

upload=true

while getopts ":d:hn" opt; do
	case ${opt} in
		h)
			usage
			exit
			;;
		d)
			seriesTag=$OPTARG
			if ! checkSeries $seriesTag
			then
				printf "${clr_red}ERROR: Unrecognized Ubuntu series '$seriesTag'.${clr_end}\n" 1>&2
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

outDir="$thisScriptDir/out"
packageVersion=$(dpkg-parsechangelog -l "$thisScriptDir/$seriesTag/debian/changelog" --show-field Version)
appVersion=$(awk -v a="$packageVersion" -v b="-" 'BEGIN{print substr(a,1,index(a,b)-1)}')
packageSrcDir="$outDir/kmeldb-ui_$packageVersion"
if [ ! -d "$packageSrcDir" ]
then
	mkdir -p "$packageSrcDir"
else
	rm -r -f "$packageSrcDir/"*
fi

echo Preparing source package...
cachedTarball="$thisScriptDir/../cache/kmeldb-ui_$appVersion.tar.gz"
if [ ! -f "$cachedTarball" ]
then
	mkdir -p "$thisScriptDir/../cache"
	curl -L https://github.com/vsvyatski/kmeldb-ui/archive/v${appVersion}.tar.gz -o "$cachedTarball"
fi
cp -T "$cachedTarball" "$outDir/kmeldb-ui_$appVersion.orig.tar.gz"
tar -xf "$outDir/kmeldb-ui_$appVersion.orig.tar.gz" -C "$packageSrcDir" --strip 1
cp -r "$thisScriptDir/$seriesTag/debian" "$packageSrcDir"
pip3 download -d "$packageSrcDir/debian/wheel" -r "$packageSrcDir/src/requirements.txt"

GPG_KEY_FINGERPRINT=0DD4B77316E9B98475C60931551726B7CE345449
DESTINATION_PPA='ppa:vsvyatski/kmeldb-ui'

echo 'Building source package...'
cd "$packageSrcDir"
debuild -S --sign-key=$GPG_KEY_FINGERPRINT
cd -

if [ ${upload} = true ]
then
	echo Uploading to Launchpad...
	cd "$outDir"
	dput $DESTINATION_PPA "$(basename "$packageSrcDir")_source.changes"
	cd -
fi

echo 'Publishing is done.'
