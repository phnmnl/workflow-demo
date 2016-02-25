#Microservices-based metabolomics workflow

Microservices is a software architecture style in which complex applications are divided into smaller, more narrow services. These constricted processes are independently deployable and compatible with one another like building blocks. In this manner, these blocks can be combined in multiple ways, creating pipelines of actions.


In this repository we aim to introduce a microservice-based infrastructure for analysis of metabolomics data. The data used has been provided by the [CARAMBA] (http://www.medsci.uu.se/caramba/) team at Uppsala University and the main products used in the analsysis workflow are Docker, Jenkins and Mantl.

>**Note**
>If you are not familiar with the concept of Docker or Mesosphere, please take a brief look at the following websites: [What is Docker?] (https://www.docker.com/what-docker),  [Meet Jenkins] (https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [Mantl.io] (https://mantl.io/).

<p align="center">
  <img src="http://i65.tinypic.com/352exkx.png" width="350"/>
</p>

The analysis workflow can be seen above, containing the following processes:

 - **BlankFilter** - For contaminants removal
 - **BatchfeatureRemoval** - Removal of batch specific features
 - **log2transformation** - Transforming the data to the log2 base scale
 - **Splitter** - Splits the data according to sample names
 - **CV** - Calculates the coefficient of variation
 - **Merger** - Merges several files into one
 - **FeatureSelection** - Extracting features with low CV

## Prerequisites

## How to develop a simple R-based microservice

In this session follows a tutorial on how to develop and integrate a R-based microservice and share it on GitHub.

###Dockerize an R script

When wrapping your R script in a Docker image you will need two files, your **R script file** and a **Dockerfile**, containing all the commands needed to assemble an image.

In this tutorial we will use one of the smallest services in this pipeline, the log2transformation. This process will take intensity data as an input using the commandArgs function in R and transform the data to log2 base scale. The missing values will be further imputed by zeros and the data exported with the desired name given.

```R
args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]
samples<-read.table(input,sep='\t',header=T)

samples=log2(samples)
samples[is.na(samples)]=0

write.table(samples,file=output,sep='\t',row.names=F)
```

In the Dockerfile you first provide which base image that you want to start **FROM**. If doing a R-based service, like we are, the base image *r-base* is a good one to start from. Further you provide the **MAINTAINER**, you **ADD** your R script and **ENTRYPOINT**, which tells the image what action to do.

```Docker
FROM r-base
MAINTAINER Stephanie Herman, stephanie.herman.3820@student.uu.se

ADD log2transformation.r /
ENTRYPOINT ["Rscript", "log2transformation.r"]
```

Before sharing your docker image on GitHub you may want to check that it does what it is supposed to do. In order to do that you first need to build your image, using the following command. To tag your image the -t flag may be used, followed by the name you desire.

```
$ docker build -t log2transformation .
```

If everything works fine it will say that the image was successfully built.

To run your service you need to provide it with the name of your input and output files and you need to add a data volume to your image containging your input file. To add/create a volume you use the -v flag followed by the path/to/your/file:path/in/image.

```
$ docker run -v /home/workflow-demo/log2transformation/data:/data log2transformation /data/data.xls /data/output.xls
```
###Share your microservice source code on GitHub

When you are satisfied with your Docker image you may want to share or store your code on GitHub. This is easly done using some basic git commands.

First you have to create your destnation repository on GitHub. Once done you need to clone your repository to your local host using the git command *clone*.

```
$ git clone https://github.com/your/repository
```

Next up is to copy your Dockerfile and your R script into the repository. Move into your repository and copy using the *cp* command. The -r flag means copy recurrsive, meaning that all your files in the folder will be copied.

```
$ cp -r path/to/files/* .
```
Add the files to your repository so that they will be tracked.

```
$ git add log2transformation Dockerfile
```

Record the changes made, while adding a message.

```
$ git commit -m "Upload Docker image files"
```

Upload your changes.

```
$ git push
```
###Continous integration with Jenkins

If you further want to upload your image on [DockerHub] (https://hub.docker.com/) and have continous integration using Jenkins, you first need to register an account DockerHub and Jenkins respectively. Once this is done you can start with creating your project in Jenkins. For continous integration between GitHub and DockerHub you will need one Jenkins item per microservice.

To create a new Jenkins item push the "Create new item" button in the top left corner (mind that the screenshots are in Swedish). 

<p align="center">
  <img src="http://i65.tinypic.com/2145ixt.png" width="750"/>
</p>

Choose "Freestyle project" and name your item.

<p align="center">
  <img src="http://i66.tinypic.com/2tyqq.jpg" width="750"/>
</p>

In the next step you will find a long list of settings. First, pass the URL to your GitHub project and check the Git box below source code management (Källskodshantering).

<p align="center">
  <img src="http://i66.tinypic.com/vq1grr.png" width="750"/>
</p>


To make the integration automatic, check the "Build when a change is pushed to GitHub" box and below "Build" choose "Execute Docker command" and add "Create/add image" as the first building-step. Add the context folder (the name of the GitHub folder of your item) and name the Docker image.

<p align="center">
  <img src="http://i65.tinypic.com/rsc2vp.png" width="750"/>
</p>

<p align="center">
  <img src="http://i65.tinypic.com/2hwjlog.png" width="750"/>
</p>

Add "Push image" as a second Docker command, passing again the name of your Docker image and the Docker regirty URL. For this step you will also need a ssh key, which can be generated in DockerHub.

<p align="center">
  <img src="http://i63.tinypic.com/2hf5fzl.png" width="750"/>
</p>

Finally, push save. your will now be redirected to the items main page. To start the building push "Start building now" in the top left corner (The rebuilding/updating will be done automatically after the initial build).

<p align="center">
  <img src="http://i64.tinypic.com/2w7kcps.png" width="750"/>
</p>

## How to deploy a microservices workflow with Mantl


## Virtual box image with Ubuntu - Docker - Jenkins

To create the Microservices cloud you require the following:

Terraform
Mantl
etc .........

We have prepared an VirtualBox Ubuntu image with all prerequisit software installed:

https://drive.google.com/file/d/0By9qLHz4UHg7eEpPOTNMdFZVcUk/view?usp=sharing

( VirtualBox installation: https://www.virtualbox.org/wiki/Downloads )

