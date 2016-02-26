
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)





csv_file<-gsub("-in=","",(args[grepl("-in",args,fixed=T)]),fixed=T)



save_dir<-gsub("-out=","",(args[grepl("-out",args,fixed=T)]),fixed=T)




output_name<-gsub("-name=","",(args[grepl("-name",args,fixed=T)]),fixed=T)


setwd(save_dir) 


data<-readLines(csv_file)
dataspt<-strsplit(data,"\t")
all<-c()
allpep<-c()
line<-1
ee<-as.data.frame(matrix(nrow=0,ncol=209))
while(line<=length(dataspt)-1)
{

  
 
  if(dataspt[[line]][1]=="\"CONSENSUS\"" & dataspt[[line+1]][1]=="\"PEPTIDE\"")
  {
    line2<-line+1
    st<-dataspt[[line+1]][1]
    allp<-c()
    while(st=="\"PEPTIDE\"")
    {
      allp<-rbind(allp,dataspt[[line2]])
      line2=line2+1
      st<-dataspt[[line2]][1]
    }
    ind<-which.min(allp[,4])
    write.table(cbind(t(dataspt[[line]]),t(allp[ind,])),"tmp_decyder.txt",sep="\t",row.names=FALSE,append=TRUE,col.names = FALSE)
    allp<-c()
    line<-line2-1
  
  }
  else if (dataspt[[line]][1]=="\"CONSENSUS\"" & dataspt[[line+1]][1]!="\"PEPTIDE\"")
  {
    write.table(cbind(t(dataspt[[line]]),t(rep(NA,12))),"tmp_decyder.txt",sep="\t",row.names=FALSE,append=TRUE,col.names = FALSE)
    
  }
  
 
  line=line+1
}
if(dataspt[[line]][1]=="\"CONSENSUS\"")
{
  write.table(cbind(t(dataspt[[line]]),t(rep(NA,12))),"tmp_decyder.txt",sep="\t",row.names=FALSE,append=TRUE,col.names = FALSE)
  
}



all<-read.table("tmp_decyder.txt", header = FALSE, sep = "\t")

names(all)<-append(dataspt[[6]],dataspt[[7]])
'
toadd<-c()

for(x in 1:dim(peps)[1])
{



for(i in 1:dim(mz[mz[,"peptide_number"]==peps[x,"number"],])[1])
{

write.table(peps[x,],"pepu.txt",sep="\t",row.names=FALSE,append=TRUE,col.names = FALSE)

}


}'

asd<-all
allmaps<-c()
for(l in 1:length(dataspt))
{
 
  if(dataspt[[l]][1]=="\"MAP\""){
    indx<-length(strsplit(dataspt[[l]][3],"\\\\|/",fixe=F)[[1]])
    nm<-  strsplit(strsplit(dataspt[[l]][3],"\\\\|/",fixe=F)[[1]][indx],".",fixed=TRUE)[[1]][1]
    num<-dataspt[[l]][2]
    allmaps<-rbind(allmaps,c(paste("_",num,sep=""),paste("_",nm,sep="")))
  }
  
}

allnames<-names(asd)
for(l in dim(allmaps)[1]:1)
{
  allnames[allnames==paste("rt",allmaps[l,1],sep="")]<-gsub(allmaps[l,1],allmaps[l,2],allnames[allnames==paste("rt",allmaps[l,1],sep="")])
  allnames[allnames==paste("mz",allmaps[l,1],sep="")]<-gsub(allmaps[l,1],allmaps[l,2],allnames[allnames==paste("mz",allmaps[l,1],sep="")])
  allnames[allnames==paste("intensity",allmaps[l,1],sep="")]<-gsub(allmaps[l,1],allmaps[l,2],allnames[allnames==paste("intensity",allmaps[l,1],sep="")])
  allnames[allnames==paste("charge",allmaps[l,1],sep="")]<-gsub(allmaps[l,1],allmaps[l,2],allnames[allnames==paste("charge",allmaps[l,1],sep="")])
  allnames[allnames==paste("width",allmaps[l,1],sep="")]<-gsub(allmaps[l,1],allmaps[l,2],allnames[allnames==paste("width",allmaps[l,1],sep="")])
  
  
}



names(asd)<-allnames
asd <- as.data.frame(lapply(asd,function(x) if(is.character(x)|is.factor(x)) gsub("\\","",x,fixed=T) else x))

write.table(asd,output_name,sep="\t",row.names=FALSE)
#file.remove("pepu.txt")
file.remove("tmp_decyder.txt")


