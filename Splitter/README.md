#Splitter - Splits data according to sample names

In order to parallelize microservices, we need to split the data into the subsets that will be processed simultaneously. The Splitter divides the data based on the five first letters of the sample names (ignoring the "intensity_" in the beginning).

**Input:** Combined .xls file containing all samples

**Output:** Several .xls files named by the samples in the subset, at the stated location.

##Run Splitter locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t splitter .
```

To run the service you need to provide it with the name of your input file and the name of the destination folder for the output files (output_splitter in the example below). You also need to add a data volume to your image containging your input file. In the example below the input data is located in the local folder *data* and a destination folder is created with the same name. 

```
$ docker run -v /home/workflow-demo/data:/data splitter /data/input.xls /data/output_splitter
```
