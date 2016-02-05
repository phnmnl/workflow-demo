args <- commandArgs(trailingOnly = TRUE)

input = args[1]
path = args[2]
output = args[3]
setwd(path)
samples<-read.table(input,sep='\t',header=T)

filenames = list.files(pattern = "*.xls")

# remove mebendazole and controls
filenames = filenames[-grep("Contr", filenames)]
filenames = filenames[-grep("Meben", filenames)]
filenames = filenames[-grep("data", filenames)]

print(filenames)
# read first file
temp = read.table(filenames[1], sep="\t", header=T)
print(length(temp))
cvs = matrix(NA, length(temp), length(filenames))
cvs[,1] = temp
 
for (i in 2:length(filenames)) {
  temp = read.table(filenames[i], sep="\t", header=T)
  cvs[,i] = temp
}

cv = apply(cvs,1,median,na.rm=T)

idx = which(cv < 0.9)
samples = samples[idx,]

write.table(samples,file=output,sep='\t',row.names=F)

