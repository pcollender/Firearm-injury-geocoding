# Firearm-injury-geocoding
Geocoding pipeline to map firearm injuries to census tracts and neighborhoods while protecting health information privacy. Relies on [DeGAUSS](https://degauss.org/) to extract latitude/longitude from address data, then assigns data points to census tracts or neighborhoods based on geoprocessing within R, flagging entries for which no precise match was obtained.

#### Cloning / Pulling Repo with Git LFS

Since some files are large, we must use Git LFS (https://git-lfs.github.com/)

Once git lfs is installed, git clone works the same way.

```sh
git clone https://github.com/pcollender/Firearm-injury-geocoding
```

To checkout new files in an existing repo with git lfs run `git lfs fetch`

Then normal git commands work the same way.

**General workflow:**
1. Preprocess data to match DeGAUSS' [input format requirements](https://github.com/degauss-org/degauss-org.github.io/wiki/Geocoding-with-DeGAUSS#address-string-formatting)
2. Run DeGAUSS shell script to obtain latitude/longitude
3. Run R script to obtain neighborhood / census tract
4. Remove PII and upload matched data to server
5. Identify errors in unmatched data and refine step 1, or flag for low quality matches and upload data


## Directory structure

**Shell script:** Will hold shell scripts to execute geocoding using DeGAUSS, and, eventually, a master shell script to run entire pipeline

**R code:** Will hold geoprocessing and bulk pre-processing scripts

**Shapefiles:** Will hold geographic data layers used to situate geocoded data in census tracts and neighborhoods

**Processed data:** Will hold output
