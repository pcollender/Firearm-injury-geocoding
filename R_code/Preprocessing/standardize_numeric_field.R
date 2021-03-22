#setwd('GitHub/Firearm-injury-geocoding/Raw_data/')
#args = c('temp_data.csv','NUMBER')
args = commandArgs(trailingOnly = T)
#should be <file name> <field name> <"zip" if field is zipcode>

if(length(args) == 2) args[3] = ''

data = read.csv(args[1], stringsAsFactors = F)

if(is.numeric(data[,args[2]])){ #remove decimal points
  data[,args[2]] = as.character(floor(data[,args[2]]))
}

if(is.character(data[,args[2]])){ #remove decimal points
  data[,args[2]] = gsub('.0', '', data[,args[2]], fixed = T)
}

if(tolower(args[3]) == "zip"){
  data[,args[2]] = substring(data[,args[2]], 1, 5)
}
cat('\n')
head(data)
cat('\nNew data written to temp_data.csv\n')
write.csv(data,'temp_data.csv', row.names = F)
