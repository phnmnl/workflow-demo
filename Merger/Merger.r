args <- commandArgs(trailingOnly = TRUE)

path = args[1]
output = args[2]
setwd(path)

filenames = list.files(pattern = "*.xls")

# remove mebendazole and controls
#filenames = filenames[-grep("Contr", filenames)]
#filenames = filenames[-grep("Meben", filenames)]

print(filenames)
# read first file
temp = read.table(filenames[1], header=T)

merged = temp 
for (i in 2:length(filenames)) {
  temp = read.table(filenames[i], sep="\t", header=T)
  merged = cbind(merged,temp)
}

write.table(merged,file=output,sep='\t',row.names=F)
