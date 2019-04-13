# Kenwood Database Generator Packaging

The repository contains the code necessary to build packages for different Linux distributions.

## ubuntu

This stuff is responsible for building source code packages for [Launchpad PPA](https://launchpad.net/~vsvyatski/+archive/ubuntu/kmeldb-ui) and uploading them. To do so, use _publish-ppa.sh_:

```console
Usage:
  publish-ppa.sh [options]

options:
  -h                      display this help message and exit
  -d <distribution_tag>   publish for a given distribution
     supported distributions:
       xenial - Xenial Xerus (16.04.* LTS). Used as a default if -d is not provided
       bionic - Bionic Beaver (18.04.* LTS)
       cosmic - Cosmic Cuttlefish (18.10)
  -n                      do not upload to Launchpad
```
