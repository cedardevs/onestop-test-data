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
Upload to locally running OneStop- 
```
./upload.sh OS . localhost:30098/onestop-admin
```
Upload to OneStop on sciapps- 
```
./upload.sh OS . sciapps.colorado.edu/onestop/api
```
Upload a specific dataset to IM's protected endpoint- 
```
./upload.sh IM COOPS sciapps.colorado.edu/registry -a user:password
```
Upload to locally running Inventory Manager w/o auth- 
```
./upload.sh COOPS localhost:8080/registry
```
Upload to Inventory Manager sciapps- 
```
./upload.sh IM . sciapps.colorado.edu/registry
```


