args <- commandArgs(trailingOnly = TRUE)

input = args[1]
input2 = args[2]
output = args[3]

samples<-read.table(input,sep='\t',header=T)
cvs<-read.table(input2,sep='\t',header=F)

cv = apply(cvs,1,median,na.rm=T)

idx = which(cv < 0.3)
samples = samples[idx,]

write.table(samples,file=output,sep='\t',row.names=F)

