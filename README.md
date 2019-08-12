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
There are two utility scripts included in this repo, `uploadOneStop.sh` and `uploadInventoryManager.sh`. These scripts provide a simple way to recursively curl the contents of a directory to their respective application's API accepting  ication/xml, namely OneStop and Inventory Manager.

### Example usage
Upload to locally running OneStop- 
```
./uploadOneStop.sh . localhost:30098/onestop-admin
```
Upload to OneStop on sciapps- 
```
./uploadOneStop.sh . sciapps.colorado.edu/onestop/api
```
Upload a specific dataset- 
```
./uploadOneStop.sh COOPS sciapps.colorado.edu/onestop/api
```
Upload to locally running Inventory Manager- 
```
./uploadInventoryManager.sh COOPS localhost:31060/registry
```
Upload to Inventory Manager sciapps- 

```
./uploadInventoryManager.sh . sciapps.colorado.edu/registry
```


