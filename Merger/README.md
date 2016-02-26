#Merger - Merges several files into one, columnwise

In order to parallelize microservices, we need to split the data into the subsets that will be processed simultaneously. This is done by the *Splitter* service. After the parallelized action of choice has been done, the results need to be further merged into a single file.

**Input:** Path to folder containing files to be merged

**Output:** A .xls file with the result files merged columnwise.

##Run Merger locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t merger .
```

To run the service you need to provide it with the name of the folder containing the input files and the name of the output file. You also need to add a data volume to your image containing your input file. In the example below the input data is located in the local folder *data* and a destination folder is created with the same name. 

```
$ docker run -v /home/workflow-demo/data:/data merger /data /data/output.xls
```
