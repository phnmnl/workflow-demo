######################
#
#   extract.names - extract unique names
#   names=extract.names(samples)
#
#####################
extract.names <- function(x){
  names=gsub("intensity_","",names(x))
  names = unique(names)
  names = strtrim(names, 5)
  return(names)
}

######################
#
#   Grep name in x
#
#####################
specgrep <- function(x,name) {
  x=x[,grep(name, names(x))]
  return(x)
}

args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]
samples<-read.table(input,sep='\t',header=T)

names = extract.names(samples)

dir.create(output)
for (i in 1:length(names)) {
  y <- specgrep(samples, names[i])
  
  filename = paste(names[i], "xls", sep=".")
  write.table(y,file=paste(output, filename, sep="/"),sep='\t',row.names=F)  
}

