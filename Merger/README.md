#Merger - Merges several files into one, columnwise

In order to parallelize microservices, we need to split the data into the subsets that will be processed simultaneously. This is done by the *Splitter* service. After the parallelized action of choice has been done, the results need to be further merged into a single file.

**Input:** Path to folder containing files to be merged

**Output:** A .xls file with the result files merged columnwise.

##Run Merger locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t merger .
```

To run the service you need to provide it with the name of your input and output files and you need to add a data volume to your image containging your input file. To add/create a volume you use the -v flag followed by the path/to/your/file:path/in/image

```
$ docker run -v /home/workflow-demo/data/output_splitter/output_cv:/data merger /data /data/output_merger.xls
```
