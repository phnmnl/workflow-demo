args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]
folder = args[3]

x<-read.table(paste(folder,input,sep="/"),sep='\t',header=T)

calc.cv <- function(x) {
  c=abs(sd(as.numeric(x))/mean(as.numeric(x)))
  return(c)
}

cv <- apply(x, 1, calc.cv) 

ifelse(!dir.exists(paste(folder, output, sep="/")), dir.create(paste(folder, output, sep="/")), FALSE)

out = paste(paste(folder, output, sep="/"), input, sep="/")

write.table(cv,file=out,sep='\t',row.names=F)

