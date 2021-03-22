args = commandArgs(trailingOnly = T)
#should be file name followed by fields to be concatenated

data = read.csv(args[1], stringsAsFactors = F)

fields = args[-1]

data$ADDRESS = do.call(paste,data[,fields])

cat('\n')
head(data)
cat('\nNew data written to temp_data.csv\n')

write.csv(data,'temp_data.csv', row.names = F)
