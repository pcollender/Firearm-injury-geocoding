@echo off

REM Navigate to data directory
cd ../../Raw_data/

REM Add a field STATE with value CA to all data entries. Note that output is saved as temp_data.csv
echo Adding single value field
Rscript ../R_code/Preprocessing/add_single_value_field.R example_input.csv STATE CA

REM Remove decimal points from house number field
echo Standardizing house numbers
Rscript ../R_code/Preprocessing/standardize_numeric_field.R temp_data.csv NUMBER

REM Standardize zip codes to five digits
echo Standardizing zip codes
Rscript ../R_code/Preprocessing/standardize_numeric_field.R temp_data.csv POSTCODE zip

REM concatenate house number, street, city, state, and zip fields to make a full address field
echo Concatenating addresses
Rscript ../R_code/Preprocessing/concatenate_fields.R temp_data.csv NUMBER STREET CITY STATE POSTCODE

echo Done! Find preprocessed data in Raw_data/temp_data.csv

PAUSE

