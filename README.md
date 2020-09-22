# onestop-test-data

Test data for OneStop and PSI

## Datasets

[COOPS](/COOPS)

[CSB](/CSB)

[DEM](/DEM) - source: https://data.noaa.gov/waf/NOAA/NESDIS/NGDC/MGG/DEM/iso/xml/

[DSCOVR](/DSCOVR)

[EdgeCases](/EdgeCases) - Various edge cases described by their titles.  

[GHRSST](/GHRSST)

[HazardImages](/HazardImages)

[OERVideos](/OERVideos)

[PaleoRecords](/PaleoRecords)  - source : https://www1.ncdc.noaa.gov/pub/data/metadata/published/paleo/iso/xml/

## Utility scripts

- `manifest.sh` updates the manifest files. Run this after adding or removing test data.
- `upload.sh` recursively curls test data to the OneStop or Inventory Manager API.

### Example usage
To update all manifests
```
./manifest.sh
```
To update one manifest
```
./manifest.sh DEM
```
For usage info
```
./upload.sh
```
```
Upload metadata to local IM registry -
```
./upload.sh IM <dirname> localhost/registry
```
See also:
  https://github.com/cedardevs/onestop/blob/master/docs/developer/quickstart.md#upload-test-data-1
