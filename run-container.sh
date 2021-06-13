#!/usr/bin/env bash
# Start a container from a clean amd64 stage3
set -e

if [ "${DEBUG}" = True ]; then
  set -x
fi

# Create volume container named "portage" with today's gentoo tree in it
# Ensure the portage image is up to date
docker pull gentoo/portage
# Clean up in case an old volume container exists
docker rm -f portage || true
# Create the new volume container
docker create --name portage gentoo/portage

# Ensure the stage3 image is up to date
docker pull gentoo/stage3

# Emerge the ebuild in a clean stage3
docker run --rm -ti \
  --cap-add=SYS_PTRACE \
  --volumes-from portage \
  -v "${HOME}/.portage-pkgdir":/var/cache/binpkgs \
  -v "${PWD}":/usr/local/portage \
  -w /usr/local/portage \
  gentoo/stage3
