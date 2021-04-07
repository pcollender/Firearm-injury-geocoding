# Firearm-injury-geocoding
Open source geocoding pipeline to map firearm injuries to census tracts and neighborhoods while protecting health information privacy. Relies on [DeGAUSS](https://degauss.org/) to extract latitude/longitude from address data, then assigns data points to census tracts or neighborhoods based on geoprocessing within R, flagging entries for which no precise match was obtained. 

**General workflow:**

Executable shell scripts are constructed to call R modules from the command line, as well as the open source geolocation tool DeGAUSS. 

Step 1. Preprocess data to match DeGAUSS' [input format requirements](https://github.com/degauss-org/degauss-org.github.io/wiki/Geocoding-with-DeGAUSS#address-string-formatting)

DeGAUSS requires a single column, with data in the format 

`<Numeric House Number> <Street Name> <City> <State (Abbreviation will work)> <5 digit Zip>`

Creation of the appropriate field can be done manually in programs such as Excel, or, where possible, modular operations can be automated in bulk using scripts, such as the R scripts provided here.

Step 2. Run DeGAUSS shell script to obtain latitude / longitude

Step 3. Match latitude and longitude to neighborhood / census tract areas in R

Step 4. Remove unnecessary identifying information and upload matched data to server

Step 5. Identify patterns in data for which geolocation failed and refine pre-processing, or flag for low quality matches and upload data

## Directory structure

**Shell_script:** Holds Windows and Unix (including Mac) shell scripts to execute the pipeline. These may need to be edited for each application if filenames, fields, and preprocessing steps differ

**R_code:** Holds modular scripts for preprocessing address fields and mapping points to census tracts and neighborhoods

**Raw_data:** Holds input and preprocessed data files

**Shapefiles:** Holds geographic data layers used to situate geocoded data in census tracts (Source: US census bureau) and neighborhoods (current Source: Zillow)

**Processed_data:** Holds finished output

## Installation

1. Clone this repository to your computer
2. Install R from https://cran.rstudio.com
3. Add R executables to the system path so they can be run from command line:
    * On Windows machines:
        * Open system properties from the Start Menu or searchbar
        ![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/Windows_path1.png)
        * Navigate to the advanced tab and clicking the 'Environmental Variables' button
        ![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/Windows_path2.png)
        ![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/Windows_path3.png)
        * In the 'User Variables for (username)' box, click the row labeled 'Path', then click the 'Edit' button
        ![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/Windows_path4.png)
        * CLick 'New', then click 'Browse' and navigate to 'This PC/C/Program Files/R/(current version folder; e.g. R-4.0.1)/bin/x64' 
        ![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/Windows_path5.png)
    * On Unix machines (incl Macs), this step shouldn't be necessary
4. On Unix machines, install necessary spatial libraries by opening terminal and running `sudo apt install libgeos-dev libgdal-dev`
5. Open R and install required spatial packages by running the command `install.packages( c('rgdal', 'sp', 'rgeos'))`
6. Install docker by following OS-appropriate prompts at https://www.docker.com/products/docker-desktop
7. Test docker installation
  * Open command prompt (on Windows) or terminal (on Unix machines), then run the line `docker run hello-world`

## Pre-processing

DeGAUSS uses input data in csv format. It requires an address field with the approximate structure '(House number) (Street) (City) (State or state abbreviation) (Zip)'
(see https://github.com/degauss-org/degauss-org.github.io/wiki/Geocoding-with-DeGAUSS)

Street numbers should be written using arabic numerals, apartment numbers and second line addresses should be omitted, and zip codes must be included. Only the first 5 digits of zip codes will be used. Do not try to geocode PO box addresses.

To avoid programming problems, do not use spaces in the filename or any fields which will be used to construct the address.

Several small R scripts have been written to accomplish pre-processing tasks from the command line these include

1. **add_single_value_field.R** 
  * Adds a field with a single value to the dataframe, e.g. if State is missing for dataset located entirely within California
  * Arguments: `<input file name> <name of field to add> <value to assign to field for all entries>`
  * Example: `Rscript add_single_value_field.R data.csv State CA`
  * Note: output will be saved as 'temp_data.csv' in the current working directory

2. **standardize_numeric_field.R** 
  * Depending on arguments, either removes decimal points from house number fields or subsets zip code fields to the first 5 digits
  * Arguments: `<input file name> <name of field to process> <optional indicator if field is zip code>`
  * Example (not zip code): `Rscript standardize_numeric_field.R temp_data.csv house_number`
  * Example (zip code): `Rscript standardize_numeric_field.R temp_data.csv postal_code zip`
  * Note: Setting the third argument zip (or ZIP, or Zip, or ZiP etc) will treat the field as a zipcode. Putting in any other value or omitting the 3rd argument will treat the field as a house number
  * Note: output will be saved as 'temp_data.csv' in the current working directory

3. **concatenate_fields.R** 
  * Concatenates multiple fields to a single address field, with each element separated by a single space
  * Arguments: `<input file name> <name of field 1 to concatenate> <name of field 2 to concatenate> ... <name of field n to concatenate>`
  * Example: `Rscript concatenate_fields.R temp_data.csv house_number street city state postal_code`
  * Note: output will be saved as 'temp_data.csv' in the current working directory

A pipeline using the example data is currently coded for windows in the executable batch file 'preprocess.bat'

## Geocoding and post-processing

Once the data is in an appropriate input format, we can use docker to run DeGAUSS to extract coordinates of each address. See https://github.com/degauss-org/degauss-org.github.io/wiki/Geocoding-with-DeGAUSS.

The first time the command is run, docker will download the DeGAUSS geocoding container, which is 6 GB. On subsequent executions, this step will not have to be repeated.

After retrieving coordinates for each point, we run postprocessing scripts in R

1. **qcReport.R** 
  * Flags rows of data with poor quality matches (or no matches) with the variable *qcPass*, and reports the number of matched and unmatched points
  * Arguments: `<input file name>`
  * Example: `Rscript qcReport.R temp_data_geoprocessed.csv`
  * Note: output will be saved as 'temp_data_geoprocessed.csv' in the current working directory

1. **tract_neighborhood_mapping.R** 
  * Loads census tract (from https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html) and neighborhood (from https://github.com/ningliang/Zillow-Neighborhoods/tree/master/data/ZillowNeighborhoods-CA) maps, and assigns each geocoded point to a neighborhood and census tract based on its location
  * Arguments: `<input file name>`
  * Example: `Rscript tract_neighborhood_mapping.R temp_data_geoprocessed.csv`
  * Note: output will be saved as 'mapped_data.csv' in the Processed_data/ directory

A pipeline using the preprocessing output of the example data is currently coded for windows in the executable batch file 'geocode.bat', in Mac and Linux in the file 'geocode.command' (referenced for Linux systems by the double-clickable executable 'geocode.desktop')

## Neighborhood coverage
Catchments are in orange, Zillow neighborhoods in red
### UCLA
![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/neighborhood_coverage_UCLA.PNG)
### Riverside
![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/neighborhood_coverage_riverside.PNG)
### Fresno
![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/neighborhood_coverage_fresno.PNG)
### Davis
![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/neighborhood_coverage_ucdavis.PNG)
### UCSD
![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/neighborhood_coverage_ucsd.PNG)
### Bay Area
![picture alt](https://github.com/pcollender/Firearm-injury-geocoding/blob/main/Readme_files/Images/neighborhood_coverage_ucsf_eastbay.PNG)
