REM Navigate to data directory
cd ../../Raw_data/

REM Call degauss geocoder. Output will be saved as temp_data_geocoded.csv
docker run --rm=TRUE -v "%cd%":/tmp degauss/geocoder temp_data.csv ADDRESS

PAUSE