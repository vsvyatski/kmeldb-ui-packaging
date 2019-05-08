# Kenwood Database Generator Packaging

The repository contains the code necessary to build packages for different Linux distributions.

## ubuntu

This stuff is responsible for building source code packages for [Launchpad PPA](https://launchpad.net/~vsvyatski/+archive/ubuntu/kmeldb-ui) and uploading them. To do so, use _publish-ppa.sh_:

```console
Usage:
  publish-ppa.sh [options]

options:
  -h                 display this help message and exit
  -d <series_tag>    publish for a given series
     supported series:
       xenial - Xenial Xerus (16.04.* LTS). Used as a default if -d is not provided
       bionic - Bionic Beaver (18.04.* LTS)
       cosmic - Cosmic Cuttlefish (18.10)
       disco  - Disco Dingo (19.04)
  -n                 do not upload to Launchpad
```

It is not always possible to build for a selected series on a given machine. For instance, you have Bionic Beaver and want to build for Disco Dingo. For that purpose there exists another script - _publish-ppa-docker.sh_. It accepts exactly the same options as _publish-ppa.sh_, but the build is performed by the means of Docker.

## archlinux

Here you can build the package for Pacman-powered systems like Arch Linux. Just run _build.sh_ and you're good to go. The resulting package can be found inside the _archlinux/out_ folder. I have an [AUR package](https://aur.archlinux.org/packages/kmeldb-ui) set up that contains certain files from the _archlinux_ folder and can be used by anyone.
