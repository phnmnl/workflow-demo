#BatchfeatureRemoval - Removal of batch specific features

In MS studies you may, if you have many samples, prepare the samples in batches. By doing so you introduce a risk of having features that are unique within a batch, which is not desirable. 

The task of this microservice is to remove features that have a coverage of 80% within one batch, but not in any other. Put in other words, remove batch specific features.

**Input:** .xls file containing samples as columns

**Output:** A .xls file with samples as columns, where batch specific features have been removed

##Run BatchfeatureRemoval locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t batchfeatureremoval.
```

To run the service you need to provide it with the names of your input and output files and you need to add a data volume to your image containging your input file. In the example below the input data is located in the local folder *data* and a destination folder is created with the same name. 

```
$ docker run -v /home/workflow-demo/data:/data batchfeatureremoval /data/input.xls /data/output.xls
```
