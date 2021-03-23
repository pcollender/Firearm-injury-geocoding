library(rgdal)
library(rgeos) #used for matching coordinates to shapefile
library(sp)

args = commandArgs(trailingOnly = T)

dat = read.csv(args[1], stringsAsFactors = F)

dat$rowid = 1:nrow(dat)

neighborhoods = readOGR('../Shapefiles/Neighborhoods/ZillowNeighborhoods-CA.shp',
                        stringsAsFactors = F)

tracts = readOGR('../Shapefiles/Census_tracts/tl_2020_06_tract.shp',
                 stringsAsFactors = F)

latlong = na.omit(dat[,c('rowid','lat','lon')])

coordinates(latlong) = ~lon+lat
latlong@proj4string <- tracts@proj4string #assign same coordinate reference system

#plot(neighborhoods,border = 'black')
#points(latlong, col = 'red', pch = 16,cex = 0.2)
#axis(1)
#axis(2)

points_in_neighborhood = over(latlong, neighborhoods)

latlong$neighborhood = points_in_neighborhood$NAME

points_in_tract = over(latlong, tracts)

latlong$tract = points_in_tract$NAME

dat = merge(dat,latlong@data,by = 'rowid')

dat$rowid = NULL

write.csv(dat, file = '../Processed_data/mapped_data.csv')
