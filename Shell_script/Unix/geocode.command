#!/bin/bash

BASEDIR=$(dirname "$0")
POSTPROCESSING_SCRIPTS="../R_code/Postprocessing"

# Navigate to data directory
cd $BASEDIR/../../Raw_data

# Call degauss geocoder. Output will be saved as temp_data_geocoded.csv
echo "Running geocoder"
sudo docker run --rm=TRUE -v $(pwd):/tmp degauss/geocoder temp_data.csv ADDRESS

# Flag and report quality of matches
echo "Checking quality of matches"
Rscript $POSTPROCESSING_SCRIPTS/qcReport.R temp_data_geocoded.csv

# Map to census tracts and neighborhoods
echo "Mapping points to census tracts and neighborhoods"
Rscript $POSTPROCESSING_SCRIPTS/tract_neighborhood_mapping.R temp_data_geocoded.csv

echo "Find output in Processed_data/mapped_data.csv!"
