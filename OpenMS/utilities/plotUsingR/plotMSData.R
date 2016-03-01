options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
if (length(args)<9) {
  stop("All the arguments need to be provided!", call.=FALSE)
}

inputFile<-gsub("-in=","",(args[grepl("-in",args,fixed=T)]),fixed=T)
outputFile<-gsub("-out=","",(args[grepl("-out",args,fixed=T)]),fixed=T)
columnPattern<-gsub("-pattern=","",(args[grepl("-pattern",args,fixed=T)]),fixed=T)
imputeOption<-gsub("-impute=","",(args[grepl("-impute",args,fixed=T)]),fixed=T)
plotType<-gsub("-plottype=","",(args[grepl("-plottype",args,fixed=T)]),fixed=T)
plotWidth<-gsub("-width=","",(args[grepl("-width",args,fixed=T)]),fixed=T)
plotHeight<-gsub("-height=","",(args[grepl("-height",args,fixed=T)]),fixed=T)
imageType<-gsub("-imagetype=","",(args[grepl("-imagetype",args,fixed=T)]),fixed=T)
log2Option<-gsub("-log=","",(args[grepl("-log",args,fixed=T)]),fixed=T)



data<-read.table(inputFile,header=T,sep = "\t",stringsAsFactors = F)
if(columnPattern!="")
{
data<-data[,grepl(names(data),pattern = columnPattern,fixed = T)]
names(data)<-gsub(columnPattern,"",names(data))
}

if(as.logical(log2Option)==T)
{
  data<-log2(data)
}
if(as.logical(imputeOption)==T)
{
  data[is.na(data)]<-0
}

plt<-NA

library(dendextend)
library(dendroextras)
library(reshape)
library(ggplot2)
library(Rmisc)

if(toupper(plotType)=="BAR")
{

  dataplot<-melt(data)
  
  dataInfo<-summarySE(dataplot, measurevar="value", groupvars=c("variable"),na.rm = T)
  dataInfo$variable<-factor(dataInfo$variable)
 plt<- ggplot(dataInfo, aes(x=variable, y=value)) + 
    geom_bar( stat="identity",width=0.4) +
    theme(axis.text.x  = element_text(size=20,face="bold",color="black",angle = 90),
          axis.text.y  = element_text(size=20,face="bold",color="black"),
          axis.title.x = element_text(face="bold", size=20),
          axis.title.y = element_text(face="bold", size=20),
          axis.line = element_line(colour = "black"),
          legend.title=element_blank(),
          legend.text= element_text(face="bold",size=20),legend.key = element_rect(fill = "white"),
          
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          panel.border=element_rect(FALSE),title=element_text(face="bold",size=20)) +
    geom_errorbar(aes(ymin=value-se, ymax=value+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.7),size=2)+ylab("")+xlab("")+guides(fill=F)+ggtitle("")
  
  
  
}else if(toupper(plotType)=="BOX")
{
  dataplot<-melt(data)
plt<-  ggplot(data = (dataplot), aes(x=variable, y=value)) + geom_boxplot()+
  theme(axis.text.x  = element_text(size=20,face="bold",color="black",angle = 90),
        axis.text.y  = element_text(size=20,face="bold",color="black"),
        axis.title.x = element_text(face="bold", size=20),
        axis.title.y = element_text(face="bold", size=20),
        axis.line = element_line(colour = "black"),
        legend.title=element_blank(),
        legend.text= element_text(face="bold",size=20),legend.key = element_rect(fill = "white"),
        
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border=element_rect(FALSE),title=element_text(face="bold",size=20))+ylab("")+xlab("")+guides(fill=F)+ggtitle("")
  
}else if(toupper(plotType)=="PCA")
{
  pca <-prcomp(cor(data), method='pearson')
  
  scores <- data.frame(names(data), pca$x[,1:3])
  names=names(data)
  
  plt<-qplot(x=pca$x[,1],y=pca$x[,2],xlab="PC1",ylab="PC2",data=scores,label=names(data))+
    scale_x_continuous()+geom_point(size=8)+ 
    geom_text(aes(label=names),hjust=0.3, vjust=2,size=5)+theme_bw()
}else if(toupper(plotType)=="TREE")
{
  
  hc_data=data.frame(data)
  d=dist(cor(hc_data, use="p",method="spearman"))
  hc=hclust(d, method="ward.D")
  dend <- as.dendrogram(hc)
  plot(hang.dendrogram(dend),dLeaf = 0)
  plt<-recordPlot()
}

if(toupper(imageType)=="JPG")
{
  jpeg(outputFile,width = as.numeric(plotWidth)*96,height = as.numeric(plotHeight)*96)
  print(plt)
  dev.off()
  
}else if(toupper(imageType)=="PNG")
{
  png(outputFile,width = as.numeric(plotWidth)*96,height = as.numeric(plotHeight)*96)
  print(plt)
  dev.off()
}else if(toupper(imageType)=="PDF")
{
  pdf(outputFile,width = as.numeric(plotWidth),height = as.numeric(plotHeight))
  print(plt)
  dev.off()
}

