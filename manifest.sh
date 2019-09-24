#!/bin/bash

usage() {
  echo "$0 [directory]"
  echo "Updates manifest files, while ensuring consistent formating and order."
  echo "  directory(optional): '.' or one of the immediate sudirectories (COOPS, DEM, etc)"
  echo "recommended: $0"
  exit 1
}

getXMLFiles() { # BASEDIR is read on stdin (use pipe to send input)
  while read BASEDIR; do
    find ${BASEDIR} -name "*.xml"
  done
}

genManifestContent() { # pipe in list of files to generate uuids for
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
