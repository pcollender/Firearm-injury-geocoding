# Firearm-injury-geocoding
Geocoding pipeline to map firearm injuries to census tracts and neighborhoods while protecting health information privacy. Relies on [DeGAUSS](https://degauss.org/) to extract latitude/longitude from address data, then assigns data points to census tracts or neighborhoods based on geoprocessing within R, flagging entries for which no precise match was obtained. 

**General workflow:**
1. Preprocess data to match DeGAUSS' [input format requirements](https://github.com/degauss-org/degauss-org.github.io/wiki/Geocoding-with-DeGAUSS#address-string-formatting)
2. Run DeGAUSS shell script to obtain latitude/longitude
3. Run R script to obtain neighborhood / census tract
4. Remove PII and upload matched data to server
5. Identify errors in unmatched data and refine step 1, or flag for low quality matches and upload data


## Directory structure

**Shell_script:** Holds Windows (and, in the future, Linux, Mac) shell scripts to execute pipeline. These may need to be edited for each application if filenames, fields, and preprocessing steps differ

**R_code:** Holds scripts for preprocessing address fields and mapping points to census tracts and neighborhoods

**Raw_data:** Holds input and preprocessed data files

**Shapefiles:** Holds geographic data layers used to situate geocoded data in census tracts (Source: US census bureau) and neighborhoods (Source: Zillow)

**Processed_data:** Holds finished output

## Installation

1. Clone this repository to your computer
2. Install R from https://cran.rstudio.com
3. Open R and install required spatial packages by running the commands 
    ```
    install.packages( c('rgdal', 'sp', 'rgeos'))
    ```
4. (on Windows) Add R executables to the system path by
  * Opening system properties from the Start Menu or searchbar
  * Navigating to the advanced tab and clicking the 'Environmental Variables' button
  * In the 'User Variables for (username)' box, click the row labeled 'Path', then click the 'Edit' button
  * CLick 'New', then click 'Browse' and navigate to 'This PC/C/Program Files/R/(current version folder; e.g. R-4.0.1)/bin/x64'
5. Install docker
  * for Windows, go to https://hub.docker.com/editions/community/docker-ce/desktop/windows/, download and run the executable
6. Test docker installation
  * on Windows, open the command prompt by typing 'cmd' into the search bar, then run the lines
```
  docker run hello-world
```

## Pre-processing

DeGAUSS uses input data in csv format. It requires an address field with the approximate structure '(House number) (Street) (City) (State or state abbreviation) (Zip)'
(see https://github.com/degauss-org/degauss-org.github.io/wiki/Geocoding-with-DeGAUSS)

Street numbers should be written using arabic numerals, apartment numbers and second line addresses should be omitted, and zip codes must be included. Only the first 5 digits of zip codes will be used. Do not try to geocode PO box addresses.

To avoid programming problems, do not use spaces in the filename or any fields which will be used to construct the address.

Several small R scripts have been written to accomplish pre-processing tasks from the command line these include

1. **add_single_value_field.R** 
  * Adds a field with a single value to the dataframe, e.g. if State is missing for dataset located entirely within California
  * Arguments: *(input file name)* *(name of field to add)* *(value to assign to field for all entries)*
  * Note: output will be saved as 'temp_data.csv' in the current working directory

2. **standardize_numeric_field.R** 
  * Depending on arguments, either removes decimal points from house number fields or subsets zip code fields to the first 5 digits
  * Arguments: *(input file name)* *(name of field to process)* *(indicator that field is zip code)*
  * Note: Setting the third argument zip (or ZIP, or Zip, or ZiP etc) will treat the field as a zipcode. Putting in any other value or omitting the 3rd argument will treat the field as a house number
  * Note: output will be saved as 'temp_data.csv' in the current working directory

3. **concatenate_fields.R** 
  * Concatenates multiple fields to a single address field, with each element separated by a single space
  * Arguments: *(input file name)* *(name of field 1 to concatenate)* *(name of field 2 to concatenate)* ... *(name of field n to concatenate)*
  * Note: output will be saved as 'temp_data.csv' in the current working directory

A pipeline using the example data is currently coded for windows in the executable batch file 'preprocess.bat'

##Geocoding and post-processing

Once the data is in an appropriate input format, we can use docker to run DeGAUSS to extract coordinates of each address. See https://github.com/degauss-org/degauss-org.github.io/wiki/Geocoding-with-DeGAUSS.

The first time the command is run, docker with download the DeGAUSS geocoding container, which is 6 GB. On subsequent executions, this step will not have to be repeated.

After retrieving coordinates for each point, we run postprocessing scripts in R

1. **qcReport.R** 
  * Flags rows of data with poor quality matches (or no matches) with the variable *qcPass*, and reports the number of matched and unmatched points
  * Arguments: *(input file name)*
  * Note: output will be saved as 'temp_data_geoprocessed.csv' in the current working directory

1. **tract_neighborhood_mapping.R** 
  * Loads census tract (from https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html) and neighborhood (from https://github.com/ningliang/Zillow-Neighborhoods/tree/master/data/ZillowNeighborhoods-CA) maps, and assigns each geocoded point to a neighborhood and census tract based on its location
  * Arguments: *(input file name)*
  * Note: output will be saved as 'mapped_data.csv' in the Processed_data/ directory

A pipeline using the preprocessing output of the example data is currently coded for windows in the executable batch file 'geocode.bat'

After all of the above steps have been completed, matched data can be de-identified by removing sensitive fields, then shared to project servers. Unmatched data can be reviewed to identify additional preprocessing steps that may allow it to be geocoded more accurately.
