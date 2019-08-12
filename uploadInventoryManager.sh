#!/bin/bash

usage(){
  echo
  echo "Usage: $0 [ -d | --directory ] <rootDir> <inventoryManagerBase> [ -m | --manifest ] <manifest> [ -a | --auth ] <AUTH>"
  echo
  echo "  rootDir         The base directory to recursively upload xml files from. This script uses the path of each file to determine type (i.e. 'collections' or 'granules' must be in the path)."
  echo "  inventoryManagerBase The URL of the root of the registry service."
  echo "                  e.g. for a locally-running API: https://localhost:8080/registry/metadata"
  echo
  exit 1
}

genManifest(){
  echo "Generating manifest with filename $MANIFEST"
  if [[ -fe "$MANIFEST" ]]; then
      echo "Deleting old manifest"
      rm -f $MANIFEST
  fi
  while read file; do
     TYPE="collection"
     UUID=$(uuidgen | awk '{print tolower($0)}')
     if [[ $file = *"granule"* ]]; then
       TYPE="granule"
     fi
     echo "$UUID $file" >> $MANIFEST
   done < <(find ${BASEDIR} -type f -name "[^.]*.xml" -print)
}


postItems(){
  while IFS=' ' read UUID FILE; do
    TYPE="collection"
    if [[ $FILE = *"granule"* ]]; then
      TYPE="granule"
    fi
    UPLOAD="$API_BASE/metadata/$TYPE"
    echo "`date` - Uploading $FILE with $UUID to $UPLOAD"
    if [[ -z $AUTH ]] ; then
      echo `curl -k -L -sS $UPLOAD/$UUID -H "Content-Type: application/xml" --data-binary "@$FILE"`
    else
      echo `curl -k -u $AUTH -L -sS $UPLOAD/$UUID -H "Content-Type: application/xml" --data-binary "@$FILE"`
    fi
  done < $MANIFEST
}

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -d|--directory)
      BASEDIR=$2
      shift 2
      ;;
    -m|--manifest)
      GEN_MANIFEST="true"
      shift 1
      ;;
    -f|--manifest-file)
      MANIFEST="$2"
      shift 2
      ;;
    -e|--endpoint)
      API_BASE=$2
      shift 2
      ;;
    -a|--auth)
      AUTH=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"



while (( "$#" )); do
  if [[ -z $BASEDIR ]]; then
    BASEDIR=$1
    shift
  fi
  if [[ -z $API_BASE ]]; then
    API_BASE=$1
    shift
  fi
  if [[ -z $AUTH ]]; then
    AUTH=$1
    shift
  fi
  if [[ -z $GEN_MANIFEST ]]; then
    if [[ $1 == 'true' ]] || [[ $1 == 'false' ]]; then
      GEN_MANIFEST=$1
    else GEN_MANIFEST='false'
    fi
    shift
  fi
  if [[ -z $MANIFEST ]]; then
    if [[ $1 ]]; then
      MANIFEST=$1
    else MANIFEST="$BASEDIR/manifest.txt"
    fi
    shift
  fi
  shift
done

echo "BASEDIR - $BASEDIR"
echo "API_BASE - $API_BASE"
echo "AUTH - $AUTH"
echo "GEN_MANIFEST - $GEN_MANIFEST"
echo "MANIFEST File - $MANIFEST"

if [[ $BASEDIR ]]; then
  if [[ $GEN_MANIFEST == "true" ]]; then
    read  -n 1 -p "Generate manifest? (y/n):" userConfirmation
    if [[ $userConfirmation == 'yes' ]] || [[ $userConfirmation == 'y' ]] || [[ $userConfirmation == 'Y' ]]; then
        genManifest
    fi
  fi
  if [[ -fe $MANIFEST ]] && [[ $API_BASE ]]; then
    read  -n 1 -p "Post items? (y/n):" userConfirmation
    if [[ $userConfirmation == 'yes' ]] || [[ $userConfirmation == 'y' ]] || [[ $userConfirmation == 'Y' ]]; then
        postItems
    fi
  fi
else usage
fi
