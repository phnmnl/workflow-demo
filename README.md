#Microservices-based metabolomics workflow

Microservices is a software architecture style in which complex applications are divided into smaller, more narrow services. These constricted processes are independently deployable and compatible with one another like building blocks. In this manner, these blocks can be combined in multiple ways, creating pipelines of actions.


In this repository we aim to introduce a microservice-based infrastructure for analysis of metabolomics data. The data used has been provided by the [CARAMBA] (http://www.medsci.uu.se/caramba/) team at Uppsala University and the main products used in the analsysis workflow are [Docker] (https://www.docker.com/what-docker), [Jenkins] (https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [MANTL] (https://mantl.io/).

>**Note**
>If you are not familiar with the concept of Docker or Mesosphere, please take a brief look at the following websites: [What is Docker?] (https://www.docker.com/what-docker),  [Meet Jenkins] (https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [mantl.io] (https://mantl.io/).

## Prerequisites

* Please sign up on [DockerHub](https://hub.docker.com/).
* Please sign up on [GitHub](https://github.com).
* Please make sure that your [Google Cloud Platform](https://cloud.google.com/) account has write access to the [PhenoMeNal](https://console.cloud.google.com/compute/instances?project=phenomenal-1145) project. In addition, you will need a *Phenomenal-credentials.json* file that will be distributed the day of the workshop, in order to fire up VMs using Terraform.
* Please download and import our [VirtualBox](https://www.virtualbox.org/) image: [microservices-workshop.ova](https://www.dropbox.com/s/42olu24n1nmq6x4/microservices-workshop.ova?dl=0). In this tutorial we assume that you run all of the commands using this image, so please make sure to import it and to configure it properly. 

>This is a configured Ubuntu 14.04 LTS with all of the software you need in this tutorial: [Terraform](https://www.terraform.io/), [MANTL dependecies](https://github.com/CiscoCloud/mantl/blob/master/requirements.txt), [Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [Docker](https://www.docker.com/what-docker).

Once you imported the image in VirtualBox you will need to open a terminal and generate an ssh-key.

```bash
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa
```

Furthermore, you will have to setup your git user.

```bash
git config --global user.email "myname@example.com"
git config --global user.name "My Name"
```

Finally, please copy the *Phenomenal-credentials.json* file under the home directory `/home/phenomenal`.

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
[MANTL](http://mantl.io/) is a modern platform for rapidly deploying globally distributed services. The MANTL project defines a set of [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) configuration files to rapidly deploy a microservices infrastructure on many cloud providers. In this section we cover how to deploy a MANTL cluster on the PhenoMeNal project in the Google Cloud Engine (GCE).

>Before to continue please take a brief look to the [MANTL architecture](https://github.com/CiscoCloud/mantl/blob/master/README.md#architecture).

First of all you need to get MANTL, which is distributed through GitHub. Please clone the official MANTL repository and locate into it.

```bash
git clone https://github.com/CiscoCloud/mantl.git
cd mantl
```

>**N.B.** We assume that you will run all of the following commands in the mantl directory.

It is good practice to never run the current version of any product that is distributed through a git repository. This applies to MANTL as well. Therefore, we want to checkout a stable version of MANTL.

```bash
git checkout 1.0.2
```

First of all we need fire up the VMs on GCE. MANTL uses Terraform to provide cloud hosts provisioning, on multiple cloud providers. This is done through the definition of several Terraform modules, that make MANTL deployment simple and repeatable. However some minimal configuration it is needed (e.g. number of controllers, edges and workers, credentials etc.). For this tutorial we prepared a Terraform configuration file [gce.tf](https://github.com/phnmnl/workflow-demo/blob/master/mantl/gce.tf) that you can download and use. This file needs to be copied in the MANTL home directory, so you can just run the following command.

```bash
https://raw.githubusercontent.com/phnmnl/workflow-demo/master/mantl/gce.tf
```

In *gce.tf* we define a small development cluster with one control node, one edge node and two resource/worker nodes. You can learn how to define such file reading the [MANTL GCE documentation](http://microservices-infrastructure.readthedocs.org/en/latest/getting_started/gce.html). 

Since in this tutorial session many people are going to deploy their own MANTL cluster we need you to customize the cluster name, in order to avoid collisions. Please locate and edit the following lines in the *gce.tf* file before to proceed.

```bash
variable "long_name" {default = "myname-mantl"} #please customize this with your name
variable "short_name" {default = "myname"} #please customize this with your name
```

We are almost ready to fire up the machines, but we need a further very important step. In the cloud ssh access to the VMs is passwordless. Therefore, your ssh key needs to be injected in the VMs. The *gce.tf* file is configured to inject *~/.ssh/id_rsa* in the VMs, hence you will have to add this key to the authentication agent, running the following command.

```bash
ssh-add ~/.ssh/id_rsa
```

Now we can run the following commands to provision the infrastructure on GCE. 

```bash
terraform get # to get the required modules
terraform plan # to see what is going to be created on GCE
terraform apply # to provision the infrastructure on GCE. Go grab a coffee. 
```

If everything went fine, you should be able to ping the instances through Ansible.

```bash
ansible all -m ping # VMs needs some time to start, if it fails try again after a while
```

Now the infrastructure is running on GCE (VMs, network, public IPs and DNS records). However, we need to install and configure all of the software, required by MANTL, on the VMs. Luckly, MANTL comes with ansible playbook that do this job.

First, we need to upgrade all of the packages on the VMs.

```bash
ansible-playbook playbooks/upgrade-packages.yml # go grab a coffee
```

MANTL comes with many components, hence we might want to install different subsets of these for different use cases. This is done by defining roles in a root Ansible playbook. We prepared one that you can use for this tutorial. Please download it in the *mantl* folder running the following command.

```bash
wget https://raw.githubusercontent.com/phnmnl/workflow-demo/master/Mantl/phenomenal.yml
```

Again, to avoid collisions with other users that are running their own cluster on the PhenoMeNal project, we need you to customize this file. Please locate and edit the following line in your *phenomenal.yml* file. 

```bash
traefik_marathon_domain: myname.phenomenal.cloud
```

>**N.B.** it is very important that you substitute *myname* with the same name you have used for the *"short_name"* variable in the *gce.tf* file. If you fail to do so, the edge nodes will not work properly. 

Now, before to install the software defined in *phenomenal.yml*, we need to setup security and define a password for our cluster. You can do this using the *security-setup* script.

```bash
./security-setup
```

Finally, we are ready to install the sofware via Ansible. Please run the following command.

```bash
ansible-playbook -e @security.yml phenomenal.yml # time for another coffee
```

If everything went fine you should be able to access the MANTL UI at: *https://control.yourname.phenomenal.cloud/ui/*. 

>To access the MANTL UI add a https exception to your browser, and log in as admin using the password that you previously chose.

If you have a warning under the *Traefik* service, run the following command. 

```bash
ansible 'role=edge' -s -m service -a 'name=traefik state=restarted'
```

>We opend a ticket for this issue (https://github.com/CiscoCloud/mantl/issues/1073), and it is hopefully going to be fixed soon. 

## Deploy long-lasting microservices on Marathon
Now that you have your MANTL cluster running, you may want to deploy some services on that. In this section we cover how to run long-lasting services through the [Marathon](https://mesosphere.github.io/marathon/) REST API. As example we will run a Jupyter server that has previously been wrapped in a Docker image.

>Before to continue you may want to read a bit about [Marathon](https://mesosphere.github.io/marathon/).

First, please clone this repository and locate into it.

```bash
git clone https://github.com/phnmnl/workflow-demo.git
cd workflow-demo
```

We wrapped the Marathon submit REST call in a small script: [marathon_submit.sh](https://github.com/phnmnl/workflow-demo/blob/master/bin/marathon_submit.sh). You can use it to deploy Jupyter on your MANTL cluster running the following commands.

```bash
source bin/set_env.sh #you will asked to enter your control node URL, and admin password
bin/marathon_submit.sh Jupyter/jupyter.json
```

The jupyter.json file is sent to Marathon through the REST API, and it defines the application that we are going yo deploy.

```json
{
	"cpus": 0.25, 
	"mem": 128,
	"id": "jupyter",
	"instances": 1,
	"labels": {"traefik.frontend.entryPoints":"http,https,ws"},
	"container": {
    "type": "DOCKER",
    "docker": {
      "image": "jupyter/minimal-notebook",
      "network": "BRIDGE",
			"privileged": true,
			"portMappings": [{
        "containerPort": 8888,
        "hostPort": 0,
        "protocol": "tcp"
      }]
    },
    "volumes": [{
      "containerPath": "/home/jovyan/work",
      "hostPath": "/mnt/container-volumes/jupyter",
      "mode": "RW"
    }]
  }
}
```

The format of this json is defined in the [Marathon REST API documentation](https://mesosphere.github.io/marathon/docs/rest-api.html). An important remark is that we mount the jupytet working directory under the `/mnt/container-volumes` folder. This is the location where the [GlusterFS](https://www.gluster.org/) distributed filesystem is mounted. Doing so, the Jupyter working directory will be accessible by other microservices, that can potentially run on other resource nodes. 

[Traefik](https://github.com/containous/traefik) is a reverse proxy that runs on the edge nodes, and it provides access to the services deployed via Marathon. Please read a bit about that. If everithing went fine, you should be able to figure out the front end URL of your Jupyter deployment from the Traefik UI (which is linked in the MANTL UI).

*N.B.* Due to an issue (https://github.com/CiscoCloud/mantl/issues/1142), the Jupyter working directory won't be writable on GlusterFS. To fix this we need to ssh into a node and change the ownership of it. 

```
ssh centos@control.myname.phenomenal.cloud
sudo chown centos /mnt/container-volumes/jupyter/
exit # closes the ssh connection
```

## Deploy microservices workflows using Chronos
We prepared a Jupyter interactive notebook that you can use to get started with Chronos. You can download it [here](https://raw.githubusercontent.com/phnmnl/workflow-demo/master/Jupyter/Workflow.ipynb), and upload it to the Jupyter server that you previously deployed on MANTL. Before going through that, please read a bit about [Chronos](https://mesos.github.io/chronos/).

