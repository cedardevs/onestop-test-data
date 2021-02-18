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

## Utility Scripts

- `manifest.sh` updates the manifest files. Run this after adding or removing test data.
- `upload.sh` recursively curls metadata to the OneStop, via the Registry API.

### Manifest Script
To update all manifests
```
./manifest.sh
```
To update the DEM manifest
```
./manifest.sh DEM
```

### Upload Script
For usage info
```
./upload.sh
```
Upload metadata to a local OneStop
```
./upload.sh <dirname> localhost/onestop/api/registry
```
Upload EdgesCases to a local OneStop
```
./upload.sh EdgeCases localhost/onestop/api/registry
```
See also:
  https://cedardevs.github.io/onestop/developer/additional-developer-info
