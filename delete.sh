#!/bin/bash

cr=`echo $'\n.'`
cr=${cr%.}

usage(){
  echo
  echo "Usage: $0 <rootDir> <baseUrl> <username:password>"
  echo
  echo "  rootDir         The base directory to recursively delete xml files from. For IM this script uses the path of each file to determine type (i.e. 'collections' or 'granules' must be in the path)."
  echo "  baseUrl         The target host and context path. The endpoint is built according to the needs to of the application, e.g. for a locally-running IM API: http://localhost/onestop/api/registry"
  echo "  username:password  (optional) The username and password for basic auth protected endpoints."
  echo
  exit 1
}

deleteFromInventoryManager() { # assumes API_BASE, AUTH are defined, UUID and FILE are read on stdin (use pipe to send file input)
  while read UUID FILE; do
    local TYPE="collection"
    if [[ $FILE = *"granule"* ]]; then
      TYPE="granule"
    fi
    local URL="$API_BASE/metadata/$TYPE/$UUID"
    echo "`date` - Deleting $TYPE with $UUID from $URL"
    if [[ -z $AUTH ]] ; then
      echo `curl -k -L -sS -X DELETE $URL`
    else
      echo `curl -k -u $AUTH -L -sS -X DELETE $URL`
    fi
  done
}

deleteItems(){
  while read MANIFEST; do
    if [[ $API_BASE ]]; then
      echo "Begin delete..."
      cat $MANIFEST | deleteFromInventoryManager
      echo "Delete completed."
    else echo "No files deleted. Specify a URL to delete files."
    fi
  done
}

ARGS_COUNT=$#
if [[ $ARGS_COUNT -eq 2 || $ARGS_COUNT -eq 3 ]]; then
  #args
  BASEDIR=$1
  MANIFESTS=$(find $BASEDIR -name "manifest.txt")
  API_BASE=$2
  AUTH=$3

  # display configuration settings
  echo $cr
  echo "Working config - confirm before proceeding."
  echo "BASEDIR - $BASEDIR"
  echo "MANIFEST FILES - $MANIFESTS"
  echo "API_BASE - $API_BASE"
  echo "AUTH - $AUTH"
  echo $cr

  # upload
  echo $MANIFESTS | xargs -n 1 | deleteItems
else
  usage
fi

