#####################
#   batchfeatures - output batch specific features
#   to.remove=remove.batchfeatures(samples)
#
#####################
remove.batchfeatures <- function(samples) {
  B1_samples=samples[,grep("B1", names(samples))]
  B2_samples=samples[,grep("B2", names(samples))]
  B3_samples=samples[,grep("B3", names(samples))]
  B4_samples=samples[,grep("B4", names(samples))]
  
  idx_1=coverage(B1_samples,0.8)
  idx_2=coverage(B2_samples,0.8)
  idx_3=coverage(B3_samples,0.8)
  idx_4=coverage(B4_samples,0.9)
  
  presence=matrix(0,dim(samples)[1],4)
  presence[idx_1,1] = 1
  presence[idx_2,2] = 1
  presence[idx_3,3] = 1
  presence[idx_4,4] = 1
  idx=0
  for (i in 1:dim(samples)[1]) {
    row=presence[i,]
    if (length(row[row==1])==1) {
      idx = c(idx,i)
    }
  }
  
  idx=idx[idx>0]
  return(idx)
}

######################
#
#   coverage - compute features with coverage of cutoff or above
#   features=coverage(samples,1)
#
#####################
coverage <- function(intensities, coverage) {
  amount = dim(intensities)
  cutoff = amount[2]*coverage
  features=rep(0,amount[1])
  
  for (i in 1:amount[1]) {
    temp=intensities[i,]
    a=!is.na(temp)
    a=which(a)
    if (length(a)>=cutoff) {
      features[i]=i
    }
  }
  features=features[which(features>0)]
  return(features)
}

args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]
samples<-read.table(input,sep='\t',header=T)

to.remove=remove.batchfeatures(samples)
if(length(to.remove)>0) {samples=samples[-to.remove,]
cat("Batch specific removed: ",length(to.remove), "\n")} else {cat("No batch specific features")}

write.table(samples,file=output,sep='\t',row.names=F)
