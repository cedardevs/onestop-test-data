#!/bin/bash

# cr=`echo $'\n.'`
# cr=${cr%.}

# usage(){
#   echo
#   echo "Usage: $0 <application> [ -d | --directory ] <rootDir> <baseUrl> [ -m | --gen-manifest ] [ -f | --manifest-file ] <manifestFile> [ -a | --auth ] <username:password>"
#   echo
#   echo "  application     OS or IM - to support differences in APIs (i.e. IM API includes record type, collection or granule)"
#   echo "  rootDir         The base directory to recursively upload xml files from. For IM this script uses the path of each file to determine type (i.e. 'collections' or 'granules' must be in the path)."
#   echo "  baseUrl         The target host and context path. The endpoint is built according to the needs to of the application, e.g. for a locally-running IM API: https://localhost:8080/registry"
#   echo "  genManifest     Only pertains to IM. Use flag [ -m | --gen-manifest ] to generate the manifest based on the contents of the rootDir."
#   echo "  manifestFile    Only pertains to IM. Relative path of the manifest file to generate and/or use for submissions. Contains a map of UUIDs to filepaths for consistent loading/re-uploading."
#   echo "  username:password  The username and password for basic auth protected endpoints."
#   echo
#   exit 1
# }

usage() {
  echo "$0 directory"
  # echo "  command: gen (-g), check (-c), append (-a)"
  echo "  directory(optional): '.' or one of the immediate sudirectories (COOPS, DEM, etc)"
  echo "recommended: $0"
  exit 1
}

getXMLFiles() { # BASEDIR is read on stdin (use pipe to send input)
  while read BASEDIR; do
    find ${BASEDIR} -name "*.xml"
  done
}

genManifestContent() {
  while read FILE ; do
    TYPE="collection"
    UUID=$(uuidgen | awk '{print tolower($0)}')
    if [[ $FILE = *"granule"* ]]; then
      TYPE="granule"
    fi
    echo "$UUID $FILE"
  done
}

genManifestFile() {
  while read BASEDIR; do
    MANIFEST=$BASEDIR/manifest.txt
    if [[ -f "$MANIFEST" ]]; then
      echo "Deleting old manifest"
      rm -f $MANIFEST
    fi
    echo $BASEDIR | getXMLFiles | genManifestContent >> $MANIFEST
    echo "Created manifest $MANIFEST"
  done
}

updateManifest() {
  while read BASEDIR; do
    MANIFEST=$BASEDIR/manifest.txt
    if [[ ! -f "$MANIFEST" ]]; then
      echo "No manifest found in $BASEDIR."
      echo $BASEDIR | genManifestFile
    else
      echo $BASEDIR | getXMLFiles | while read FILE; do
        if ! grep -Fq "$FILE" "$MANIFEST"
        then
          echo "Adding $FILE to $MANIFEST"
          echo $FILE | genManifestContent >> $MANIFEST
        fi
      done
    fi
    echo $BASEDIR | sortManifest
  done
}

sortManifest() {
  while read BASEDIR; do
    MANIFEST=$BASEDIR/manifest.txt
    TMP=$BASEDIR/tmp.txt
    cat $MANIFEST | while read uuid file; do
      echo $file $uuid
    done | sort > $TMP
    rm $MANIFEST
    cat $TMP | while read file uuid; do
      echo $uuid $file
    done >> $MANIFEST
    rm $TMP
  done
}

# sortManifestContents() {
#   while read MANIFEST; do
#     cat $MANIFEST | while read uuid file; do
#       echo $file $uuid
#     done | sort | while read file uuid; do
#     echo $uuid $file
#   done > $MANIFEST
#   done
# }

# genManifest(){
#   #generate a new manifest if specified
#   # or if user is trying to upload with non-existent manifest to IM
#   if [[ $GEN_MANIFEST == "true" ]] || [[ $APP == 'IM' && ! -f $MANIFEST ]]; then
#     if [[  -z $FORCE ]] ; then
#       read  -n 1 -p "Generate manifest with filename $MANIFEST? (y/n): $cr" userConfirmation
#       echo $cr
#     fi
#     if [[ $FORCE || $userConfirmation == 'y' ]] ; then
#       echo "Generating manifest with filename $MANIFEST"
#
#       # while read file; do
#       #    TYPE="collection"
#       #    UUID=$(uuidgen | awk '{print tolower($0)}')
#       #    if [[ $file = *"granule"* ]]; then
#       #      TYPE="granule"
#       #    fi
#       #    echo "$UUID $file" >> $MANIFEST
#       #  done < <(find  ${BASEDIR} \( \! -regex '.*/\..*' \) -type f -name "[^.]*.xml" -print)
#       manifest="$BASEDIR/manifest.txt"
#       echo $BASEDIR | getXMLFiles | genManifestContent >> $manifest
#       echo "Created manifest $MANIFEST"
#     else echo "exiting..." ; exit 1
#     fi
#   else
#     if [[ $APP == 'IM' ]]; then
#       echo "Using existing manifest $MANIFEST"
#     fi
#   fi
# }


# GEN_MANIFEST="false"
#
# # Step 1- parse out args passed via option, shift other args as needed
# #must do this first to ensure arg order below
# PARAMS=""
# while (( "$#" )); do
#   case "$1" in
#     -d|--directory)
#       BASEDIR=$2
#       shift 2
#       ;;
#     -m|--gen-manifest)
#       GEN_MANIFEST="true"
#       shift
#       ;;
#     -f|--manifest-file)
#       MANIFEST="$2"
#       shift 2
#       ;;
#     -e|--endpoint)
#       API_BASE=$2
#       shift 2
#       ;;
#     -a|--auth)
#       AUTH=$2
#       shift 2
#       ;;
#     -F |--force)
#       FORCE='true'
#       shift 1
#       ;;
#     --) # end argument parsing
#       shift
#       break
#       ;;
#     -*|--*=) # unsupported flags
#       echo "Error: Unsupported flag $1" >&2
#       exit 1
#       ;;
#     *) # preserve positional arguments
#       PARAMS="$PARAMS $1"
#       shift
#       ;;
#   esac
# done
# # set positional arguments in their proper place
# eval set -- "$PARAMS"
#
# #Step 2 - parse args to env vars
# #arg  order
# while (( "$#" )); do
#   if [[ -z $APP ]]; then
#     APP=$1
#     shift
#   fi
#   if [[ -z $BASEDIR ]]; then
#     BASEDIR=$1
#     if [[ $BASEDIR == '.' || $BASEDIR == './' ]]; then
#       echo "LIST DIRS INSTEAD"
#       BASEDIR=$(find . -type d -depth 1 -not -path '*/\.*')
#     fi
#     shift
#   fi
#   if [[ -z $API_BASE ]]; then
#     API_BASE=$1
#     shift
#   fi
#   if [[ $APP == 'IM' && -z $MANIFEST ]]; then
#     if [[ $1 ]]; then
#       MANIFEST=$1
#     else MANIFEST=$(find $BASEDIR -name "manifest.txt")
#     # FOO=$(find $BASEDIR -name "manifest.txt")
#     # echo "CHECK CHECK"
#     # echo $FOO
#     # echo "Yar"
#       #"./manifest.txt"
#     fi
#     shift
#   fi
#   if [[ -z $AUTH ]]; then
#     AUTH=$1
#     shift
#   fi
#   shift
# done
#
# #Step 3 - echo working configuration
# echo $cr
# echo "Working config - confirm before proceeding."
# echo "APP - $APP"
# echo "BASEDIR - $BASEDIR"
# echo "API_BASE - $API_BASE"
# if [[ $APP == 'IM' ]]; then
#   echo "GEN_MANIFEST - $GEN_MANIFEST"
#   echo "MANIFEST File - $MANIFEST"
# fi
# echo "AUTH - $AUTH"
# echo $cr
#
# #Step 4 - proceed to generate the manifest and post if indicated.
# #we need at least the  app and the basedir to know what to do
# if [[ $APP ]] && [[ $BASEDIR ]] ; then
#   # while read manifest ; do
#   #   echo "doin stuff with $manifest"
#   #   # genManifest $manifest
#   # done < echo $MANIFEST
#   # echo "check check"
#   # echo $MANIFEST
#   # echo "uhhh"
#   # echo $MANIFEST | xargs -n1
#   echo "????"
#   # echo $MANIFEST | xargs -n1 | getXMLFiles
#   # echo $BASEDIR | xargs -n1 | getXMLFiles
#   # echo $BASEDIR | getXMLFiles
#   # genManifest
#   # postItems
# else echo "Not enough info to continue. Check working config above. Must specify at least an application and directory." ; usage
# fi

BASEDIRS="$1"
if [[ $BASEDIRS == '' ||  $BASEDIRS == '.' || $BASEDIRS == './' ]]; then
  #BASEDIRS=$(find . -type d -depth 1 -not -path '*/\.*')
  BASEDIRS=$(ls -d */ | sed 's#/##') # list subdirs with correct formatting for consistency (remove trailing '/')
else
  if [[ $BASEDIRS == './'* ]]; then
    # make sure it does not start with './' for manifest format consistency
    # BASEDIRS="./$BASEDIRS"
    BASEDIRS=$(echo $BASEDIRS | sed 's#^./##')
  fi
  if [[ $BASEDIRS == *'/' ]]; then
    # remove trailing '/' (prevents double slash in path names later)
    BASEDIRS=$(echo $BASEDIRS | sed 's#/$##')
  fi
fi

# Update (override) manifest files!
# echo $BASEDIRS | xargs -n 1 | genManifestFile

# echo $BASEDIRS | xargs -n 1 | checkManifestFile

echo $BASEDIRS | xargs -n 1 | updateManifest
