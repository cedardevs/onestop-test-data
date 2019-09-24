#!/bin/bash

cr=`echo $'\n.'`
cr=${cr%.}

usage(){
  echo
  echo "Usage: $0 <application> <rootDir> <baseUrl> <username:password>"
  echo
  echo "  application     OS or IM - to support differences in APIs (i.e. IM API includes record type, collection or granule)"
  echo "  rootDir         The base directory to recursively upload xml files from. For IM this script uses the path of each file to determine type (i.e. 'collections' or 'granules' must be in the path)."
  echo "  baseUrl         The target host and context path. The endpoint is built according to the needs to of the application, e.g. for a locally-running IM API: https://localhost:8080/registry"
  echo "  username:password  (optional) The username and password for basic auth protected endpoints."
  echo
  exit 1
}

postToInventoryManager() { # assumes API_BASE, AUTH are defined, UUID and FILE are read on stdin (use pipe to send file input)
  while read UUID FILE; do
    local TYPE="collection"
    if [[ $FILE = *"granule"* ]]; then
      TYPE="granule"
    fi
    local UPLOAD="$API_BASE/metadata/$TYPE/$UUID"
    echo "`date` - Uploading $FILE with $UUID to $UPLOAD"
    if [[ -z $AUTH ]] ; then
      echo `curl -k -L -sS $UPLOAD -H "Content-Type: application/xml" --data-binary "@$FILE"`
    else
      echo `curl -k -u $AUTH -L -sS $UPLOAD -H "Content-Type: application/xml" --data-binary "@$FILE"`
    fi
  done
}

postToOneStop() { # assumes API_BASE is defined, reads FILE is read on stdin (use pipe to send file input)
  while read UUID FILE; do
  UPLOAD="$API_BASE/metadata"
  echo "`date` - Uploading $FILE to $UPLOAD : `curl -L -sS $UPLOAD -H "Content-Type: application/xml" -d "@$FILE"`"
  done
}

postItems(){
  while read MANIFEST; do
    if [[ $API_BASE ]]; then
      echo "Begin upload..."
      if  [[ $APP == 'IM' ]]; then
        cat $MANIFEST | postToInventoryManager
      else
        cat $MANIFEST | postToOneStop
        UPDATE="$API_BASE/admin/index/search/update"
        echo "`date` - Triggering search index update: `curl -L -sS $UPDATE`"
      fi
      echo "Upload completed."
    else echo "No files uploaded. Specify a URL to upload files."
    fi
  done
}

ARGS_COUNT=$#
if [[ $ARGS_COUNT -eq 3 || $ARGS_COUNT -eq 4 ]]; then
  #args
  APP=$1
  BASEDIR=$2
  MANIFESTS=$(find $BASEDIR -name "manifest.txt")
  API_BASE=$3
  AUTH=$4

  # display configuration settings
  echo $cr
  echo "Working config - confirm before proceeding."
  echo "APP - $APP"
  echo "BASEDIR - $BASEDIR"
  echo "MANIFEST FILES - $MANIFESTS"
  echo "API_BASE - $API_BASE"
  echo "AUTH - $AUTH"
  echo $cr

  # upload
  echo $MANIFESTS | xargs -n 1 | postItems
else
  usage
fi
