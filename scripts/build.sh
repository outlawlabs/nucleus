#!/usr/bin/env bash
set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do SOURCE="$(readlink "$SOURCE")"; done
ROOTDIR="$(cd -P "$(dirname "$SOURCE")/.." && pwd)"

usage() {
  echo -e "\
Usage: $0 [options]
  -h, --help                    Help
  -b, --base {image}            Docker base to build (i.e. nucleus)
  -d, --distro {distro}         Docker base distro to build (i.e. bionic)
"
}

push_images() {

  latest=$1
  image=$2
  hashImage=$3
  gitBranch=$4

  echo "Pushing images: "
  echo " + $hashImage"
  docker push "$hashImage"
  echo " + $image"
  docker push "$image"

  if [ "$gitBranch" == "master" ]; then
    echo " + $latest"
    docker push "$latest"
  fi
}

containerize() {

  if [ -z "$DISTRO" ]; then
    echo "image distro cannot be empty"
    exit 1
  fi

  if [ -z "$BASE" ]; then
    echo "image base cannot be empty"
    exit 1
  fi

  local image
  local hashImage
  local repositoryName
  local gitCommit
  local gitBranch
  local gitUrl
  local buildDate

  repositoryName="outlawlabs/nucleus"

  gitCommit=$(git rev-parse HEAD)
  gitBranch=$(git rev-parse --abbrev-ref HEAD)
  gitUrl=$(git config --get remote.origin.url)
  buildDate=$(date +'%Y%m%d')

  latest="$repositoryName:latest"
  image="$repositoryName:$DISTRO"
  hashImage="$repositoryName:$DISTRO-$buildDate"

  echo "Building images: "
  echo " + $latest"
  echo " + $image"
  echo " + $hashImage"
  echo ""

  docker build \
    -t "$image" \
    -t "$hashImage" \
    -t "$latest" \
    --build-arg GIT_BRANCH="$gitBranch" \
    --build-arg GIT_COMMIT="$gitCommit" \
    --build-arg GIT_URL="$gitUrl" \
    --build-arg BUILD_DATE="$buildDate" \
    "$ROOTDIR/$BASE/$DISTRO"

  # Push the built docker images
  push_images "$latest" "$image" "$hashImage" "$gitBranch"
}

BASE=""
DISTRO=""

while [ "$1" != "" ]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -b | --base)
      BASE="$2"
      if [ -z "$BASE" ]; then
        echo "base image cannot be empty"
        exit 1
      fi
      shift 2
      ;;
    -d | --distro*)
      DISTRO="$2"
      if [ -z "$DISTRO" ]; then
        echo "distro cannot be empty"
        exit 1
      fi
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

containerize
