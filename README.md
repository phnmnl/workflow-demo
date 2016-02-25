#Microservices-based metabolomics workflow

Microservices is a software architecture style in which complex applications are divided into smaller, more narrow services. These constricted processes are independently deployable and compatible with one another like building blocks. In this manner, these blocks can be combined in multiple ways, creating pipelines of actions.


In this repository we aim to introduce a microservice-based infrastructure for analysis of metabolomics data. The data used has been provided by the [CARAMBA] (http://www.medsci.uu.se/caramba/) team at Uppsala University and the main products used in the analsysis workflow are [Docker] (https://www.docker.com/what-docker), [Jenkins] (https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [MANTL] (https://mantl.io/).

>**Note**
>If you are not familiar with the concept of Docker or Mesosphere, please take a brief look at the following websites: [What is Docker?] (https://www.docker.com/what-docker),  [Meet Jenkins] (https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [mantl.io] (https://mantl.io/).

## Prerequisites
* Please download and import our [VirtualBox](https://www.virtualbox.org/) image: [microservices-workshop.ova](https://www.dropbox.com/s/42olu24n1nmq6x4/microservices-workshop.ova?dl=0).

>This is a configured Ubuntu 14.04 LTS with all of the software you need in this tutorial: [Terraform](https://www.terraform.io/), [MANTL dependecies](https://github.com/CiscoCloud/mantl/blob/master/requirements.txt), [Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [Docker](https://www.docker.com/what-docker).

* Please sign up on [DockerHub](https://hub.docker.com/).
* Please sign up on [GitHub](https://github.com).
* Please make sure that your [Google Cloud Platform](https://cloud.google.com/) account has write access to the [PhenoMeNal](https://console.cloud.google.com/compute/instances?project=phenomenal-1145) project. In addition, you will need a *Phenomenal-credentials.json* file that will be distributed the day of the workshop, in order to fire up VMs using Terraform.

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

In the Dockerfile you first provide which base image that you want to start **FROM**. If doing a R-based service, like we are, the base image *r-base* is a good one to start from. Further you provide the **MAINTAINER**, youn **ADD** your R script and **ENTERYPOINT**, which tells the image what action to do.

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

In the Jenkins items configurations you need to provide the url for your GitHub project. You further needs to choose the build trigger "Build when change is pushed to GitHub", since you want your changes to be integrated in DockerHub. When building you intially want your Jenkins action to Create/build your image and then further push your image to your DockerHub repository. Make sure that the images tag is consitent throughout the actions. When everything is filled in correctly and saved, cross your fingers and push the "Star building now" button. To see the console output, you can enter the current building action and you will find a button for this on your left.

## How to deploy MANTL
```
git clone https://github.com/CiscoCloud/mantl.git
cd mantl
git checkout 1.0.2
./security-setup
wget https://raw.githubusercontent.com/phnmnl/workflow-demo/master/Mantl/gce.tf
#edit cluster name
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa
ssh-add ~/.ssh/id_rsa
#copy phenomenal credentials in home folder
terraform get
terraform plan
terraform apply
ansible all -m ping
ansible-playbook playbooks/upgrade-packages.yml
wget https://raw.githubusercontent.com/phnmnl/workflow-demo/master/Mantl/phenomenal.yml
#customize the domain name
ansible-playbook -e @security.yml phenomenal.yml
```
