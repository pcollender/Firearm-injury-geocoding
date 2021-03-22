args = commandArgs(trailingOnly = T)
#should be <file name> <new field name> <new field value>

data = read.csv(args[1], stringsAsFactors = F)

data[,args[2]] <- args[3]

cat('\n')
head(data)
cat('\nNew data written to temp_data.csv\n')

write.csv(data,'temp_data.csv', row.names = F)
