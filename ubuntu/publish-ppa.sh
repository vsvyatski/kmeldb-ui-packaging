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
    echo '  -h                      display this help message and exit'
    echo '  -d <distribution_tag>   publish for a given distribution'
    echo '     supported distributions:'
    echo '       xenial - Xenial Xerus (16.04.* LTS). Used as a default if -d is not provided'
    echo '       bionic - Bionic Beaver (18.04.* LTS)'
}

checkDistribution() {
    test $1 = xenial -o $1 = bionic
}

# Xenial Xerus (the oldest supported distribution) is the default for this script if not told otherwise
distributionTag=xenial

while getopts ":d:h" opt; do
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

# First of all we need to build the distribution
echo Started application build.
echo
sh "$thisScriptDir/build.sh"
if [ $? != 0 ]
then
    printf "${clr_red}ERROR: Distribution build failed, stopping PPA publishing.${clr_end}\n" 1>&2
    exit 1
fi
echo
echo Finished application build.

outDir="$thisScriptDir/out/ppa"
packageVersion=$(dpkg-parsechangelog -l "$thisScriptDir/packaging/deb/$distributionTag/debian/changelog" --show-field Version)
appVersion=$(python3 "$thisScriptDir/packaging/print_version.py")
packageSrcDir="$outDir/kmeldb-ui_$packageVersion"
if [ ! -d "$packageSrcDir" ]
then
	mkdir -p "$packageSrcDir"
else
	rm -r -f "$packageSrcDir/"*
fi

echo Preparing source package...
# Let's copy the distribution files
cp -r "$thisScriptDir/dist/kmeldb-ui" "$packageSrcDir"
cp "$thisScriptDir/packaging/com.github.vsvyatski.kmeldb-ui.desktop" "$packageSrcDir"
# Let's copy Makefile
cp "$thisScriptDir/packaging/deb/$distributionTag/Makefile" "$packageSrcDir"
# We have things ready to create an orig.tar.xz archive
cd "$packageSrcDir"
tar -cJf "../kmeldb-ui_$appVersion.orig.tar.xz" *
cd -
# And finally, let's copy the debian directory
cp -r "$thisScriptDir/packaging/deb/$distributionTag/debian" "$packageSrcDir"

echo Building package...
gpgKeyId=551726B7CE345449
cd "$packageSrcDir"
debuild -S --sign-key=$gpgKeyId
cd -
