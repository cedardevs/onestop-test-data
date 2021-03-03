#!/bin/bash

cr=`echo $'\n.'`
cr=${cr%.}

usage(){
  echo
  echo "Usage: $0 <rootDir> <baseUrl> <username:password>"
  echo
  echo "  rootDir         The base directory to recursively upload xml files from. This script uses the path of each file to determine the type (i.e. 'collections' or 'granules' must be in the path)."
  echo "  baseUrl         The target host and context path, e.g. for a locally-running OneStop API: http://localhost/onestop/api/registry"
  echo "  username:password  (optional) The username and password for basic auth protected endpoints."
  echo
  exit 1
}

postToRegistry() { # assumes API_BASE, AUTH are defined, UUID and FILE are read on stdin (use pipe to send file input)
  local COLLECTION_UUID=""
  local outputDir="output"
  `mkdir $outputDir`

  while read UUID FILE; do
    local TYPE="collection"
    local MEDIA="xml"
    if [[ $FILE = *"collection"* ]]; then
      COLLECTION_UUID="$UUID"
    fi
    if [[ $FILE =~ ".json" ]]; then
      MEDIA="json"
    fi
    if [[ $FILE = *"granule"* ]]; then
      TYPE="granule"
    fi
    local UPLOAD="$API_BASE/metadata/$TYPE/$UUID"
    echo "`date` - Uploading $MEDIA $FILE with $UUID to $UPLOAD"
    local outputDir="output"
    local response=""

    if [[ -z $AUTH ]] ; then
      response=`curl -k -L -sS $UPLOAD -H "Content-Type: application/$MEDIA" --data-binary "@$FILE" --create-dirs -o output/$UUID -w "%{http_code}" --silent --output /dev/null`
      if [[ $TYPE == "granule" && $MEDIA == "xml" ]]; then
        response=`curl --request PATCH -k -L -sS $UPLOAD -H 'Content-Type: application/json' -d '{'relationships':[{'id':'$COLLECTION_UUID','type':'COLLECTION'}]}' --create-dirs -o output/$UUID -w "%{http_code}" --silent --output /dev/null`
      fi
    else
      response=`curl -k -u $AUTH -L -sS $UPLOAD -H "Content-Type: application/$MEDIA" --data-binary "@$FILE" --create-dirs -o output/$UUID -w "%{http_code}" --silent --output /dev/null`
      if [[ $TYPE == "granule" && $MEDIA == "xml" ]]; then
        response=`curl --request PATCH -k -u $AUTH -L -sS $UPLOAD -H 'Content-Type: application/json' -d '{'relationships':[{'id':'$COLLECTION_UUID','type':'COLLECTION'}]}' --create-dirs -o output/$UUID -w "%{http_code}" --silent --output /dev/null`
      fi
    fi
    printf "HTTP Response: %s\n\n" "$response"
  done
}

postItems(){
  while read MANIFEST; do
    if [[ $API_BASE ]]; then
      echo "Begin upload..."
      cat $MANIFEST | postToRegistry
      echo "Finished upload."
    else echo "No files uploaded. Specify a URL to upload files."
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
  echo $MANIFESTS | xargs -n 1 | postItems
else
  usage
fi
