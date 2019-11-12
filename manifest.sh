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
    TYPE="collection"
    UUID=$(uuidgen | awk '{print tolower($0)}')
    if [[ $FILE = *"granules"* ]]; then
      TYPE="granule"
    fi
    echo "$UUID $FILE"
  done
}

updateManifest() {
  while read BASEDIR; do
    MANIFEST=$BASEDIR/manifest.txt
    if [[ ! -f "$MANIFEST" ]]; then
      echo $BASEDIR | getFiles | genManifestContent >> $MANIFEST
      >&2 echo "Created manifest $MANIFEST"
    else
      echo $BASEDIR | getFiles | while read FILE; do
        if ! grep -Fq "$FILE" "$MANIFEST"
        then
          >&2 echo "Adding $FILE to $MANIFEST"
          echo $FILE | genManifestContent >> $MANIFEST
        fi
      done
    fi
    echo $MANIFEST | sortManifest
  done
}

sortManifest() {
  while read MANIFEST; do
    TMP=$MANIFEST.tmp
    cat $MANIFEST | while read uuid file; do
      if [[ -f "$file" ]]; then
        echo $file $uuid
      else
        >&2 echo "Removing $file from $MANIFEST"
      fi
    done | sort > $TMP
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
