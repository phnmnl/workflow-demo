AdvancedBlankFilter <- function(blanks, samples, cutoff) {
  blanks[is.na(blanks)] <- 0
  samples[is.na(samples)] <- 0
      
  blanks <- apply(blanks,1,median,na.rm=TRUE)
  samples <- apply(samples,1,max,na.rm=TRUE)
	    
  to.remove <- which(blanks/samples >= cutoff)
  return(to.remove)
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

######################
#
#   Remove name in x
#
#####################
removegrep <- function(x,name) {
  x=x[,-grep(name, names(x))]
  return(x)
  }

#args <- commandArgs(trailingOnly = TRUE)

#hh <- paste(unlist(args),collapse=' ')
#listoptions <- unlist(strsplit(hh,'--'))[-1]
#options.args <- sapply(listoptions,function(x){
         #unlist(strsplit(x, ' '))[-1]
        #})
#options.names <- sapply(listoptions,function(x){
 # option <-  unlist(strsplit(x, ' '))[1]
#})
#names(options.args) <- unlist(options.names)
#print(options.args)

samples<-read.table("inputfile.xls",sep='\t',header=T)
#print(names(samples))

# separate blanks
Blanks=specgrep(samples,"BLANK")
samples=removegrep(samples,"BLANK")

to.remove<-AdvancedBlankFilter(Blanks,samples,0.01)
samples=samples[-to.remove,]
cat("GJ", "\n")

#write.table(samples,file=args,sep='\t',row.names=F)
