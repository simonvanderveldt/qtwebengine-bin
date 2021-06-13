#!/usr/bin/env bash
# Emerges and creates binpkgs for dev-qt/qtwebengine and all its dependencies
set -e

if [ "${DEBUG}" = True ]; then
  set -x
fi

# Enable binpkg-multi-instance for keeping binpkgs built with different USE flags
# Disable news messages from portage as well as the IPC, network and PID sandbox to get rid of the
# "Unable to unshare: EPERM" messages without requiring the container to be run in privileged mode
# Disable rsync output
export FEATURES="binpkg-multi-instance -news -ipc-sandbox -network-sandbox -pid-sandbox"
export PORTAGE_RSYNC_EXTRA_OPTS="-q"
# Don't store any elogs by default
export PORTAGE_ELOG_SYSTEM="echo"

# Globally enable the bindist USE flag just to be safe
echo 'USE="bindist"' >> /etc/portage/make.conf

# Set make jobs
echo MAKEOPTS="-j$(nproc)" >> /etc/portage/make.conf

# Show emerge info for troubleshooting purposes
emerge --info

# Set portage's distdir to /tmp/distfiles
# This is a workaround for a bug in portage/git-r3 where git-r3 can't
# create the distfiles/git-r3 directory when no other distfiles have been
# downloaded by portage first, which happens when using binary packages
# https://bugs.gentoo.org/481434
export DISTDIR="/tmp/distfiles"

# Emerge qtwebengine and all its dependencies
echo "Emerging dev-qt/qtwebengine"
emerge --quiet-build --buildpkg --usepkg --autounmask=y --autounmask-continue=y --autounmask-keep-keywords=y --autounmask-keep-masks=y dev-qt/qtwebengine

# Clean up binpkgs for which there's no ebuild available anymore
echo "Emerging app-portage/gentoolkit"
emerge -q --buildpkg --usepkg app-portage/gentoolkit
echo "Cleaning up old binpkgs"
eclean packages
