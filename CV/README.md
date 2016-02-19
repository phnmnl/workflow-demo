#CV - Calculates the coefficient of variation

The CV microservice calculates the coefficient of variation for each feature present within the samples.

**Input:** .xls file containing samples as columns

**Output:** .xls file with vector containing CV:s, one per feature

##Run CV locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t cv .
```

To run the service you need to provide it with the name of your input and output files and you need to add a data volume to your image containging your input file. To add/create a volume you use the -v flag followed by the path/to/your/file:path/in/image

```
$ docker run -v /home/workflow-demo/data/output_splitter:/data cv Vincr.xls output_cv /data
```
