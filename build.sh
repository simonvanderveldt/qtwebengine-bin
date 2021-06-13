#!/usr/bin/env bash
# Emerge qtwebengine in a clean amd64 stage3
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
docker run --rm \
	-e GITHUB_TOKEN \
	-e CIRCLECI \
	-e CIRCLE_PROJECT_USERNAME \
	-e CIRCLE_PROJECT_REPONAME \
	-e CIRCLE_PULL_REQUEST \
	-e CIRCLE_PR_NUMBER \
	-e DEBUG \
  --cap-add=SYS_PTRACE \
  --volumes-from portage \
  -v "${HOME}/.portage-pkgdir":/var/cache/binpkgs \
  -v "${PWD}":/usr/local/portage \
  -w /usr/local/portage \
  gentoo/stage3 \
  /usr/local/portage/resources/emerge-qtwebengine.sh
