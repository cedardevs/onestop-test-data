#!/bin/bash

if [ $# != 2 ]; then
  echo
  echo "Usage: $0 <rootDir> <inventoryManagerBase>"
  echo
  echo "  rootDir         The base directory to recursively upload xml files from. This script uses the path of each file to determine type (i.e. 'collections' or 'granules' must be in the path)."
  echo "  inventoryManagerBase The URL of the root of the registry service."
  echo "                  e.g. for a locally-running API: https://localhost:8080/registry/metadata"
  echo
  exit 1
fi

BASEDIR="$1"
API_BASE="$2"
INFO="$API_BASE/actuator/info"
COLLECTIONS_ENDPOINT="$API_BASE/collections"
GRANULES_ENDPOINT="$API_BASE/granules"

NEXT_WAIT_TIME=0
MAX_WAIT_TIME=8
until curl -sS ${INFO} || [ ${NEXT_WAIT_TIME} -eq ${MAX_WAIT_TIME} ]; do
  echo "Waiting for Registry API"
  sleep $(( NEXT_WAIT_TIME++ ))
done
if [ ${NEXT_WAIT_TIME} -eq ${MAX_WAIT_TIME} ]; then
  echo "Registry API unavailable"
  exit 1
fi

while read file; do
  echo "`date` - Uploading $file to $UPLOAD : `curl -L -sS $COLLECTIONS_ENDPOINT -H "Content-Type: application/xml" -d "@$file"`"
done < <(find ${BASEDIR} -type f -name "[^.]*.xml" -print | grep collections)

while read file; do
  echo "`date` - Uploading $file to $UPLOAD : `curl -L -sS $GRANULES_ENDPOINT -H "Content-Type: application/xml" -d "@$file"`"
done < <(find ${BASEDIR} -type f -name "[^.]*.xml" -print | grep granules )

