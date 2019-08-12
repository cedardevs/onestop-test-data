#!/bin/bash

usage(){
  echo
  echo "Usage: $0 <application> [ -d | --directory ] <rootDir> <baseUrl> [ -m | --manifest ] [ -f | --manifest-file ] <manifestFile> [ -a | --auth ] <username:password>"
  echo
  echo "  application     OS or IM - to support differences in APIs (i.e. IM API includes type, collection or granule)"
  echo "  rootDir         The base directory to recursively upload xml files from. This script uses the path of each file to determine type (i.e. 'collections' or 'granules' must be in the path)."
  echo "  baseUrl         The target host and context path. The endpoint is built according to the needs to of the application, e.g. for a locally-running IM API: https://localhost:8080/registry"
  echo "  genManifest     Use flag -m to generate the manifest based on the contents of the rooDir."
  echo "  manifestFile    Relative path of the manifest file to generate and/or use for submissions. Contains a map of UUIDs to filepaths for consistent loading/re-uploading."
  echo "  username:password  The username and password for basic auth protected endpoints."
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
    if [[ $APP == 'IM' ]]; then
      UPLOAD="$API_BASE/metadata/$TYPE/$UUID"
    else
      UPLOAD="$API_BASE/metadata"
    fi
    echo "`date` - Uploading $FILE with $UUID to $UPLOAD"
    if [[ -z $AUTH ]] ; then
      echo `curl -k -L -sS $UPLOAD -H "Content-Type: application/xml" --data-binary "@$FILE"`
    else
      echo `curl -k -u $AUTH -L -sS $UPLOAD -H "Content-Type: application/xml" --data-binary "@$FILE"`
    fi
  done < $MANIFEST
}

#parse out args passed via option, shift other args as needed
#must do this first to ensure arg order below
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -d|--directory)
      BASEDIR=$2
      shift 2
      ;;
    -m|--manifest)
      GEN_MANIFEST="true"
      shift
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


#order by arg precedence
while (( "$#" )); do
  if [[ -z $APP ]]; then
    APP=$1
    shift
  fi
  if [[ -z $BASEDIR ]]; then
    BASEDIR=$1
    shift
  fi
  if [[ -z $API_BASE ]]; then
    API_BASE=$1
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
  if [[ -z $AUTH ]]; then
    AUTH=$1
    shift
  fi
  shift
done

cr=`echo $'\n.'`
cr=${cr%.}

echo $cr
echo "Working config - confirm before proceeding."
echo "APP - $APP"
echo "BASEDIR - $BASEDIR"
echo "API_BASE - $API_BASE"
echo "GEN_MANIFEST - $GEN_MANIFEST"
echo "MANIFEST File - $MANIFEST"
echo "AUTH - $AUTH"
echo $cr

if [[ $APP ]] && [[ $BASEDIR ]] && [[ $MANIFEST ]]; then
  if [[ $GEN_MANIFEST == "true" ]]; then
    read  -n 1 -p "Generate manifest? (y/n): $cr" userConfirmation
    echo $cr
    if [[ $userConfirmation == 'yes' ]] || [[ $userConfirmation == 'y' ]] || [[ $userConfirmation == 'Y' ]]; then
        genManifest
    else echo "exiting..." ; exit 1
    fi
  fi
  if [[ -fe $MANIFEST ]] && [[ $API_BASE ]]; then
    read  -n 1 -p "Post items? (y/n): $cr" userConfirmation
    if [[ $userConfirmation == 'yes' ]] || [[ $userConfirmation == 'y' ]] || [[ $userConfirmation == 'Y' ]]; then
        postItems
    else echo "exiting..." ; exit 1
    fi
  fi
else usage
fi
