args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]

x<-read.table(input,sep='\t',header=T)

calc.cv <- function(x) {
  c=abs(sd(as.numeric(x))/mean(as.numeric(x)))
  return(c)
}

cv <- apply(x, 1, calc.cv) 

write.table(cv,file=output,sep='\t',row.names=F)

