FROM r-base

RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.rstudio.com'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('Rmisc')"
RUN Rscript -e "install.packages('ggplot2')"
RUN Rscript -e "install.packages('dendextend')"
RUN Rscript -e "install.packages('reshape')"
RUN Rscript -e "install.packages('dendroextras')"
RUN Rscript -e "install.packages('ggdendro')"


ADD plot.R /
ENTRYPOINT ["Rscript", "plot.R"] 
