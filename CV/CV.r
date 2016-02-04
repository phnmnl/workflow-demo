args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]

print(input)
print(output)

x<-read.table(input,sep='\t',header=T)

calc.cv <- function(x) {
  c=abs(sd(as.numeric(x))/mean(as.numeric(x)))
  return(c)
}

cv <- apply(x, 1, calc.cv) 

dir.create(output)

write.table(cv,file=paste(output, substring(input,6), sep="/"),,sep='\t',row.names=F)

