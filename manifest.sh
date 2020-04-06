#!/bin/bash

# usage() {
#   echo "$0 [directory]"
#   echo "Updates manifest files, while ensuring consistent formating and order."
#   echo "  directory(optional): '.' or one of the immediate sudirectories (COOPS, DEM, etc)"
#   echo "recommended: $0"
#   exit 1
# }

getFiles() { # BASEDIR is read on stdin (use pipe to send input)
  while read BASEDIR; do
    find ${BASEDIR} -name "*.xml" -o -name "*.json"
  done
}

genManifestContent() { # pipe in list of files to generate uuids for
  while read FILE ; do
    if [[ $FILE = *"collection"* ]]; then
      IDENTIFIER=$(grep fileIdentifier $FILE -A1 | grep CharacterString  | cut -d'>' -f 2 |  cut -d '<'  -f 1)
      if ! grep -Fq "$FILE" "$MANIFEST"
      then
        UUID=$(uuidgen | awk '{print tolower($0)}')
        echo "$UUID $FILE"
      else UUID=$(grep $FILE $MANIFEST | cut -d ' ' -f1 ) #get existing collection  uuid
      fi
      gatherGranules
    fi
  done
}

gatherGranules() {
  GRANULE_FILES=$(grep -rlE "($IDENTIFIER|$UUID)" $BASEDIR/granules)
  for GRANULE in $GRANULE_FILES
  do
    if ! grep -Fq "$GRANULE" "$MANIFEST"
    then
      GRANULE_UUID=$(uuidgen | awk '{print tolower($0)}')
      printf '%s\n' /^$UUID/a "$GRANULE_UUID $GRANULE" . w q | ex -s $MANIFEST #insert granule after collection
    fi
  done
}

updateManifest() {
  while read BASEDIR; do
    MANIFEST=$BASEDIR/manifest.txt
    if [[ ! -f "$MANIFEST" ]]; then
      echo $BASEDIR | getFiles | genManifestContent >> $MANIFEST
      >&2 echo "Created manifest $MANIFEST"
    else
      echo $BASEDIR | getFiles | genManifestContent >> $MANIFEST
      >&2 echo "Updated manifest $MANIFEST"
    fi
    echo $MANIFEST | sortManifest
  done
}

sortManifest() {
  while read MANIFEST; do
    TMP=$MANIFEST.tmp
    cat $MANIFEST | while read uuid file; do
      if [[ -f "$file" ]]; then
        echo $file $uuid >> $TMP
      else
        >&2 echo "Removing $file from $MANIFEST"
      fi
    done
    rm $MANIFEST
    cat $TMP | while read file uuid; do
      echo $uuid $file
    done >> $MANIFEST
    rm $TMP
  done
}

BASEDIRS="$1"
if [[ $BASEDIRS == '' ||  $BASEDIRS == '.' || $BASEDIRS == './' ]]; then
  BASEDIRS=$(ls -d */ | sed 's#/##') # list subdirs with correct formatting for consistency (remove trailing '/')
else
  if [[ $BASEDIRS == './'* ]]; then
    # make sure it does not start with './' for manifest format consistency
    BASEDIRS=$(echo $BASEDIRS | sed 's#^./##')
  fi
  if [[ $BASEDIRS == *'/' ]]; then
    # remove trailing '/' (prevents double slash in path names later)
    BASEDIRS=$(echo $BASEDIRS | sed 's#/$##')
  fi
fi
echo $BASEDIRS | xargs -n 1 | updateManifest
