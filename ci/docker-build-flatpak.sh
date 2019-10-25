#!/bin/sh  -xe
cd $(dirname $(readlink -fn $0))

#
# Actually build the Travis flatpak artifacts inside the Fedora container
#
set -xe

df -h
cd $TOPDIR
su -c 'echo proxy=http://192.168.1.1:3142 >> /etc/dnf/dnf.conf'
su -c "cat /etc/dnf/dnf.conf"
su -c "dnf install -y sudo cmake gcc-c++ flatpak-builder flatpak make tar"
su -c "dnf install -y sudo dnf-plugins-core"
sudo dnf builddep  -y ci/opencpn-fedora.spec
flatpak remote-add --user --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user  -y \
    http://opencpn.duckdns.org/opencpn/opencpn.flatpakref
flatpak install --user -y  flathub org.freedesktop.Sdk//18.08 
rm -rf build && mkdir build && cd build
cmake -DOCPN_FLATPAK=ON ..
make flatpak-build
make flatpak-pkg
