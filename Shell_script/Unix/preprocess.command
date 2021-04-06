#!/bin/bash

BASEDIR=$(dirname "$0")
PREPROCESSING_SCRIPTS="../R_code/Preprocessing"

# Navigate to data directory
cd $BASEDIR/../../Raw_data

# Add a field STATE with value CA to all data entries. Note that output is saved as temp_data.csv
echo "Adding single value field"
Rscript $PREPROCESSING_SCRIPTS/add_single_value_field.R example_input.csv STATE CA

# Remove decimal points from house number field
echo "Standardizing house numbers"
Rscript $PREPROCESSING_SCRIPTS/standardize_numeric_field.R temp_data.csv NUMBER

# Standardizing zip codes to five digits
echo "Standardizing zip codes"
Rscript $PREPROCESSING_SCRIPTS/standardize_numeric_field.R temp_data.csv POSTCODE zip

# Concatenate house number, street, city, state, and zip fields to make a full address field
echo "Concatenating addresses"
Rscript $PREPROCESSING_SCRIPTS/concatenate_fields.R temp_data.csv NUMBER STREET CITY STATE POSTCODE

echo "Done! Find preprocessed data in Raw_data/temp_data.csv"
