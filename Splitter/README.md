#Splitter - Splits data according to sample names

In order to parallelize microservices, we need to split the data into the subsets that will be processed simultaneously. The Splitter divides the data based on the five first letters of the sample names (ignoring the "intensity_" in the beginning).

**Input:** Combined .xls file containing all samples

**Output:** Several .xls files named by the samples in the subset, at the stated location.

##Run Splitter locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t splitter .
```

To run the service you need to provide it with the name of your input and output files and you need to add a data volume to your image containging your input file. To add/create a volume you use the -v flag followed by the path/to/your/file:path/in/image

```
$ docker run -v /home/workflow-demo/BlankFilter/data:/data log2transformation /data/output_log2transformation.xls /data/output_splitter.xls
```
