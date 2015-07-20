#!/bin/bash

usage() {
  echo "Clean up capistrano release dir (max 5)"
  echo "Usage:"
  echo "$0"
  echo "  -d <cap release directory> "
  echo "  -r <rleases to keep, default 5>"
  echo "  -v verbose"
  exit 1
}

while getopts "d:r:v" opt; do
  case $opt in
    d)
      PHP_DIRECTORY=${OPTARG}
    ;;
    r)
      RELEASES=${OPTARG}
    ;;
    v)
      VERBOSE="true"
    ;;
    *)
      usage
    ;;
  esac
done

if ! [ ${PHP_DIRECTORY} ]; then
  usage
fi

if ! [ ${RELEASES} ]; then
  RELEASES="5"
fi

if [ ! -d ${PHP_DIRECTORY} ]; then
  if [ "${VERBOSE}" == 'true' ]; then
    echo "no successful deployments have been completed"
  fi
  exit 55;
fi

#grab the current dir and ensure we never ever remove it (reverse it to get the last field as it outputs full path
current_release_directory=$(readlink ${PHP_DIRECTORY}/../current | rev | cut -d '/' -f1 | rev)
directorys_to_delete=$(ls -1t ${PHP_DIRECTORY} | grep -v ${current_release_directory} | tail -n +${RELEASES})

for directory in ${directorys_to_delete}; do
  if [ "${VERBOSE}" == 'true' ]; then
    echo "removing ${PHP_DIRECTORY}/${directory}"
  fi
  rm -rf ${PHP_DIRECTORY}/${directory}
done

