# onestop-test-data
Test data for OneStop and PSI 

## Datasets

[COOPS](/COOPS)

[DEM](/DEM) - source: https://data.noaa.gov/waf/NOAA/NESDIS/NGDC/MGG/DEM/iso/xml/

[DSCOVR](/DSCOVR) 

[GHRSST](/GHRSST)

[HazardImages](/HazardImages)

[OERVideos](/OERVideos)

[PaleoRecords](/PaleoRecords)  - source : https://www1.ncdc.noaa.gov/pub/data/metadata/published/paleo/iso/xml/

[EdgeCases](/EdgeCases) - Various edge cases described by their titles.  

## Utility scripts
In this repo there is a utility script, `upload.sh`, that provides a simple way to recursively curl the contents of a directory to the OneStop or Inventory Manager API.

### Example usage
For usage info 
```
./upload.sh
```
Upload a specific dataset (DEM) to a locally running OneStop- 
```
./upload.sh OS DEM localhost:30098/onestop-admin
```
Upload everything to OneStop on sciapps- 
```
./upload.sh OS . sciapps.colorado.edu/onestop/api
```
Upload edge cases to local IM registry - 
```
./upload.sh IM EdgeCases localhost:30997/registry
```
Upload everything to IM's protected endpoint on sciapps- 
```
./upload.sh IM . sciapps.colorado.edu/registry -a username:password
```

Real example loading Inventory Manager sciapps (w/o existing manifest or file)- 
```
$ ./upload.sh IM DEM sciapps.colorado.edu/registry 

Working config - confirm before proceeding.
APP - IM
BASEDIR - DEM
API_BASE - sciapps.colorado.edu/registry
GEN_MANIFEST - false
MANIFEST File - DEM/manifest.txt
AUTH - 

Generate manifest? (y/n):
y
Generating manifest with filename DEM/manifest.txt
Post items? (y/n):
y
Mon Aug 12 13:53:25 MDT 2019 - Uploading DEM/collections/gov.noaa.ngdc.mgg.dem:741.xml with 68b73de2-656b-4952-8b2b-67680240c6cb to sciapps.colorado.edu/registry/metadata/collection/68b73de2-656b-4952-8b2b-67680240c6cb
{"id":"68b73de2-656b-4952-8b2b-67680240c6cb","type":"collection"}
Mon Aug 12 13:53:27 MDT 2019 - Uploading...
...

$ git commit DEM/manifest.txt
```