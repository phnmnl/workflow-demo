#Microservices-based infrastructure for metabolomics

Microservices is a software architecture style in which complex applications are divided into smaller, more narrow services. These constricted processes are independently deployable and compatible with one another like building blocks. In this manner, these blocks can be combined in multiple ways, creating pipelines of actions.


In this repository we aim to introduce a microservice-based infrastructure for analysis of metabolomics data, through a series of examples that we encourage you to try yourself. The data used has been provided by the [CARAMBA] (http://www.medsci.uu.se/caramba/) team at Uppsala University. 

The main products used here are [Docker] (https://www.docker.com/what-docker), [Jenkins] (https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [MANTL] (https://mantl.io/).

>**Note**
>If you are not familiar with this products, please take a brief look at the following websites: [What is Docker?] (https://www.docker.com/what-docker),  [Meet Jenkins] (https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [mantl.io] (https://mantl.io/).

## Table of contents

- [Prerequisites](#prerequisites)
- [How to develop a simple R-based microservice](#how-to-develop-a-simple-r-based-microservice)
	- [Develop microservices with Docker](#develop-microservices-with-docker)
	- [Share your microservice source code on GitHub](#share-your-microservice-source-code-on-github)
	- [Continuous integration with Jenkins](#continuous-integration-with-jenkins)
- [How to deploy MANTL](#how-to-deploy-mantl)
- [Deploy long-lasting microservices on Marathon](#deploy-long-lasting-microservices-on-marathon)
- [Deploy microservices workflows using Chronos](#deploy-microservices-workflows-using-chronos)
- [How to destroy a MANTL cluster](#how-to-destroy-a-mantl-cluster) 

## Prerequisites

* Please sign up on [DockerHub](https://hub.docker.com/).
* Please sign up on [GitHub](https://github.com).
* Please make sure that your [Google Cloud Platform](https://cloud.google.com/) account has write access to the [PhenoMeNal](https://console.cloud.google.com/compute/instances?project=phenomenal-1145) project. In addition, you will need a *Phenomenal-credentials.json* file. This file will be distributed during the workshop in Uppsala.
* Please download and import our [VirtualBox](https://www.virtualbox.org/) image: [microservices-workshop.ova](http://pele.farmbio.uu.se/dl/microservices-workshop.ova) (**username**: phenomenal, **password**: scilifelab). In this tutorial we assume that you run all of the commands using this image, so please make sure to import it and to configure it properly. 

>**Note**
>This VirtualBox image is a configured Ubuntu 14.04 LTS with all of the software you need in this tutorial: [Terraform](https://www.terraform.io/), [MANTL dependecies](https://github.com/CiscoCloud/mantl/blob/master/requirements.txt), [Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) and [Docker](https://www.docker.com/what-docker).

Once you imported and started the image in VirtualBox you need to open a terminal and generate an ssh-key.

```bash
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa
```

Furthermore, you have to setup your git user.

```bash
git config --global user.email "myname@example.com"
git config --global user.name "My Name"
```

Finally, please copy the *Phenomenal-credentials.json* file under the home directory `/home/phenomenal`. (fom USB-stick)

## How to develop a simple R-based microservice

When migrating your monolitic workflow to a microservice-based infrastructure, you will have to split it in smaller, interchangeable, tasks. This is anyway a general good practice to follow when you develop your software, that will promote *separation of concern* and reusability. 

Here we propose a microservice infrastructure based on MANTL. In MANTL, complex applications are built deploying Docker containers that act as microservices. When separating your application in Docker containers, it is important to find a good strategy to share data between them. In MANTL, [GlusterFS](https://www.gluster.org/) is used to provide a distributed filesystem where containers, that can potentially run on different nodes, can share data. Therefore, you can assume that each microservice in a complex workflow reads the input, and it writes the output, form some volume that will be mounted by MANTL. 

Here we use a workflow by the Kultima lab as benchmark. In this tutorial you will deploy your very own MANTL cluster, and run this workflow using an interactive Jupyter [notebook](https://github.com/phnmnl/workflow-demo/blob/master/Jupyter/Workflow.ipynb). Please give a quick look to it before to proceed with the next section. 

###Develop microservices with Docker

In this section we show how to wrap a simple R-script in a Docker image, that can act as a microservice in a more complex workflow. For the best learning experience, we recommend that you repeat every step on your own.  

Here we use one of the smallest services in the benchmark pipeline, the [log2transformation](https://github.com/phnmnl/workflow-demo/tree/master/log2transformation). This process will take intensity data as an input, and transform it to the log2 base scale. The missing values will be further imputed by zeros. Please notice that in this R script, the data is read/write from/to the disk.

```R
args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]
samples<-read.table(input,sep='\t',header=T)

samples=log2(samples)
samples[is.na(samples)]=0

write.table(samples,file=output,sep='\t',row.names=F)
```

All you need to do in order to wrap this script in a Docker image is to write a [Dockerfile](https://docs.docker.com/engine/reference/builder/). An example follows.

```Docker
FROM r-base
MAINTAINER Stephanie Herman, stephanie.herman.3820@student.uu.se

ADD log2transformation.r /
ENTRYPOINT ["Rscript", "log2transformation.r"]
```

In the Dockerfile you first specify a base image that you want to start **FROM**. If you are working to an R-based service, like we are doing, the base image *r-base* is a good choice, as it includes all of the dependencies you need to run your script. Then, you provide the **MAINTAINER**, that is typically your name and a contact.

The last two lines in our simple Docker file are the most important. The **ADD** instruction serves to add a file in the build context to a directory in your Docker image. In fact, we use it to add our *log2transformation.r* script in the root directory. Finally, the *ENTRYPOINT* instruction, specifies which command to run when the container will be started. Of course, we use it to run our script.

When you are done with the Dockerfile, you need to build the image. The `docker build` command does the job. 

```
$ docker build -t log2transformation .
```

In the previous command we build the image, naming it *log2transformation*, and specifying the current directory as the build context. To successfully run this command, it is very important that the build context, the current directory, contains both the *Dockerfile* and the *log2transformation.r* script. If everything works fine it will say that the image was successfully built.

The `docker run` command serves to run a service that has been previously built. You can use this [input data](https://raw.githubusercontent.com/phnmnl/workflow-demo/master/data/log2_input.xls) to try out the following command.

```
$ docker run -v /host/directory/data:/data log2transformation /data/log2_input.xls /data/log2_output.xls
```

In the previous command we use the `-v` argument to specify a directory on our host machine, that will be mount on the Docker container. This directory is supposed to contain the [log2_input.xls](https://raw.githubusercontent.com/phnmnl/workflow-demo/master/data/log2_input.xls) file. Then we specify the name of the container that we aim to run (*log2transformation*), and the arguments that will be passed to the entry point command. We mounted the host direcory under */data* in the Docker container, hence we use the arguments to instruct the R script to read/write the input from/to it.    

You can read more on how to develop Docker images on the Docker [documentation](https://docs.docker.com/). 

###Share your microservice source code on GitHub

When you are satisfied with your Docker image, it is good practice to share the Dockerfile and and all of the Docker context on GitHub. This can be easily done using some basic git commands.

First you need to [create a repository on GitHub](https://help.github.com/articles/create-a-repo/), and to [clone the repository](https://help.github.com/articles/cloning-a-repository/) to your local host. Next up, following our previous R-based example, is to copy your Dockerfile and your R script into the repository folder that you just cloned.

Then, locate into the repository, and add the files to be tracked.

```
$ git add log2transformation Dockerfile
```

Commit the changes, adding a message.

```
$ git commit -m "docker image files"
```

Push your changes to GitHub.

```
$ git push
```

###Continuous integration with Jenkins

[Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins) is a convenient Continuous Integration (CI) tool that can be used to automate Docker builds. A typical use case is to share the Docker context of your appliance on GitHub, and to configure Jenkins to trigger a build every time there is a change on your master branch. Furthermore, Jenkins can automatically push the built images on DockerHub, so that your users can run them out-of-the-box.    

In the VM image that we provided in the prerequisites section, there is a Jenkins server running on [http://localhost:8080/](http://localhost:8080/).

A Jenkins item defines how to perform a build of an application. To create a new Jenkins item click on "New item". 

<p align="center">
  <img src="http://i67.tinypic.com/2qkrw3k.png" width="750"/>
</p>

Choose "Freestyle project" and name your item.

<p align="center">
  <img src="http://i64.tinypic.com/14se62r.png" width="750"/>
</p>

In the next step you will find a long list of settings. Check the GitHub project checkbox, and insert the URL to your repository. Then, further down, select Git under source management and insert the repository URL again. This second setting is very important, as the URL that you insert here will be used by Jenkins to clone your repository. 

<p align="center">
  <img src="http://i63.tinypic.com/2zzqddk.png" width="750"/>
</p>

To make the build automatic, check "Build when a change is pushed to GitHub". In this way Jenkins will expose a *webhook* that GitHub can use to trigger the builds. This means that you need to [configure the Jenkins webhook on GitHub](http://learning-continuous-deployment.github.io/jenkins/github/2015/04/17/github-jenkins/). For the purpose of this tutorial you can skip this step, and you can trigger the build manually. 

In order to configure Jenkins to build your image, click on *"Add build step"*, choose *"Execute Docker command"*, and select the *"Create/build image"* command. Add the *"Build context folder"*, that is the folder where the Docker context is saved. Setting this field to *"$WORKSPACE"* is enough if you saved the Docker context in the root of your repository. If you saved the Docker context in a different folder, you need to specify the path to it (e.g. *"$WORKSPACE/context"*). It is also very important to name the *"Tag of the resulting docker image"* properly. In fact, to successfully push to DockerHub, the tag will have to be in the form: `<dockerhub-user>/servicename`.

<p align="center">
  <img src="http://i64.tinypic.com/2mo4bat.png" width="750"/>
</p>

To push the resulting image to GitHub, add another build step, but this time select the *"Push image"*. Then, specify the *"Name of the image to push"*, that is *dockerhub-user/servicename*, and the *"Docker registry URL"*: https://index.docker.io/v1/. You need to provide the credentials for the *dockerhub-user* that you specified. In order to do that click on "Add", next to *"Registry credentials"*, fill up the form that will show up, and finally select the credentials that you just created. 

<p align="center">
  <img src="http://i67.tinypic.com/2nja42e.png" width="750"/>
</p>

Finally, save your item, and you will be redirected to the items main page. To trigger the build, click on *"Build now"* in the top left corner. A new item will appear in the *"Build History"*, and you will be able to click on it to get some statistics.  

<p align="center">
  <img src="http://i63.tinypic.com/qn5oav.png" width="750"/>
</p>

## How to deploy MANTL
[MANTL](http://mantl.io/) is a modern platform for rapidly deploying globally distributed services. The MANTL project defines a set of [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) configuration files to rapidly deploy a microservices infrastructure on many cloud providers. In this section we cover how to deploy a MANTL cluster on the PhenoMeNal project in the Google Cloud Engine (GCE).

>**Note**
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
wget https://raw.githubusercontent.com/phnmnl/workflow-demo/master/mantl/gce.tf
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
wget https://raw.githubusercontent.com/phnmnl/workflow-demo/master/mantl/phenomenal.yml
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

Finally, we are ready to install the software via Ansible. Please run the following command.

```bash
ansible-playbook -e @security.yml phenomenal.yml # time for another coffee
```

If everything went fine you should be able to reach the MANTL UI at: *https://control.yourname.phenomenal.cloud/ui/*. 

>To access the MANTL UI add a https exception to your browser, and log in as admin using the password that you previously chose.

If you have a warning under the *Traefik* service, run the following command. 

```bash
ansible 'role=edge' -s -m service -a 'name=traefik state=restarted'
```

>We opend a ticket for this issue (https://github.com/CiscoCloud/mantl/issues/1073), and it is hopefully going to be fixed soon. 

## Deploy long-lasting microservices on Marathon
Now that you have your MANTL cluster running, you may want to deploy some services on that. In this section we cover how to run long-lasting services through the [Marathon](https://mesosphere.github.io/marathon/) REST API. As example we will run a Jupyter server that has previously been wrapped in a Docker image.

>**Note**
>Before to continue you may want to read a bit about [Marathon](https://mesosphere.github.io/marathon/).

First, please clone this repository and locate into it.

```bash
git clone https://github.com/phnmnl/workflow-demo.git
cd workflow-demo
```

We wrapped the Marathon submit REST call in a small script: [marathon_submit.sh](https://github.com/phnmnl/workflow-demo/blob/master/bin/marathon_submit.sh). You can use it to deploy Jupyter on your MANTL cluster running the following commands.

```bash
source bin/set_env.sh #you will asked to enter your control node hostname (without https://), and admin password 
bin/marathon_submit.sh Jupyter/jupyter.json
```

The jupyter.json file is sent to Marathon through the REST API, and it defines the application that we are going to deploy.

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

[Traefik](https://github.com/containous/traefik) is a reverse proxy that runs on the edge nodes, and it provides access to the services deployed via Marathon. Please read a bit about that. If everything went fine, you should be able to figure out the front end URL of your Jupyter deployment from the Traefik UI (which is linked in the MANTL UI).

**N.B.** Due to an issue (https://github.com/CiscoCloud/mantl/issues/1142), the Jupyter working directory won't be writable on GlusterFS. To fix this we need to ssh into a node and change the ownership of it. 

```bash
ssh centos@control.myname.phenomenal.cloud
sudo chown centos /mnt/container-volumes/jupyter/
exit # closes the ssh connection
```

## Deploy microservices workflows using Chronos
We prepared a Jupyter interactive notebook that you can use to get started with Chronos. You can download it [here](https://raw.githubusercontent.com/phnmnl/workflow-demo/master/Jupyter/Workflow.ipynb), and upload it to the Jupyter server that you previously deployed on MANTL. 

>**Note**
>Before going through the notebook, please read a bit about [Chronos](https://mesos.github.io/chronos/).


## How to destroy a MANTL cluster

When you are done with your testing, you can run the following command to delete your MANTL cluster. 

```bash
terraform destroy
```

It is important that you don't leave your cluster up and running, if you are not using it, otherwise we will waste GCE credits. 
