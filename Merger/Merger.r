args <- commandArgs(trailingOnly = TRUE)

path = args[1]
output = args[2]
setwd(path)

filenames = list.files(pattern = "*.xls")

# remove mebendazole and controls
filenames = filenames[-grep("Contr", filenames)]
filenames = filenames[-grep("Meben", filenames)]

print(filenames)
# read first file
temp = read.table(filenames[1], sep="\t", header=T)
print(length(temp))
merged = matrix(NA, length(temp), length(filenames))
merged[,1] = temp
 
for (i in 2:length(filenames)) {
  temp = read.table(filenames[i], sep="\t", header=T)
  merged[,i] = temp
}


write.table(merged,file=output,sep='\t',row.names=F)

