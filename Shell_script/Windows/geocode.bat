@echo off

REM Navigate to data directory
cd ../../Raw_data/

echo Running geocoder
REM Call degauss geocoder. Output will be saved as temp_data_geocoded.csv
docker run --rm=TRUE -v "%cd%":/tmp degauss/geocoder temp_data.csv ADDRESS

echo Checking quality of matches
REM Flag and report quality of matches
Rscript ../R_code/Postprocessing/qcReport.R temp_data_geocoded.csv

echo Mapping points to census tracts and neighborhoods
REM Map to census tracts and neighborhoods
Rscript ../R_code/Postprocessing/tract_neighborhood_mapping.R temp_data_geocoded.csv

echo Find output in Processed_data/mapped_data.csv!

PAUSE