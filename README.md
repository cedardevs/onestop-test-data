# onestop-test-data

Test metadata for OneStop.

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
- `upload.sh` recursively curls metadata to the OneStop, via the Registry API.

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
Upload metadata to local OneStop -
```
./upload.sh <dirname> localhost/registry
```
See also:
  https://github.com/cedardevs/onestop/blob/master/docs/developer/quickstart.md#upload-test-data-1
