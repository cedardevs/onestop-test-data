#!/bin/bash

if [ $# != 2 ]; then
  echo
  echo "Usage: $0 <rootDir> <metadataAPIBase>"
  echo
  echo "  rootDir         The base directory to recursively upload xml files from."
  echo "  metadataAPIBase The URL of the root of the api-metadata service."
  echo "                  e.g. for a locally-running API: https://localhost:8080/onestop/api"
  echo
  exit 1
fi

BASEDIR="$1"
API_BASE="$2"
INFO="$API_BASE/actuator/info"
UPLOAD="$API_BASE/metadata"
UPDATE="$API_BASE/admin/index/search/update"

NEXT_WAIT_TIME=0
MAX_WAIT_TIME=8
until curl -sS ${INFO} || [ ${NEXT_WAIT_TIME} -eq ${MAX_WAIT_TIME} ]; do
  echo "Waiting for Metadata API"
  sleep $(( NEXT_WAIT_TIME++ ))
done
if [ ${NEXT_WAIT_TIME} -eq ${MAX_WAIT_TIME} ]; then
  echo "Metadata API unavailable"
  exit 1
fi

while read file; do
  echo "`date` - Uploading $file to $UPLOAD : `curl -L -sS $UPLOAD -H "Content-Type: application/xml" -d "@$file"`"
done < <(find ${BASEDIR} -type f -name "[^.]*.xml" -print)

echo "`date` - Triggering search index update: `curl -L -sS $UPDATE`"