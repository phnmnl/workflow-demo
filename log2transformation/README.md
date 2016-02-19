#log2transformation - Transforming the data to the log2 base scale

To approximate normal distribution, feature intensities are regularly transformed to the log2 base scale. Additionally missing values are imputed by zeros.

**Input:** .xls file containing samples as columns

**Output:** .xls file containing samples as columns, with intensities on the log2 base scale

##Run log2transformation locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t log2transformation .
```

To run the service you need to provide it with the name of your input and output files and you need to add a data volume to your image containging your input file. To add/create a volume you use the -v flag followed by the path/to/your/file:path/in/image

```
$ docker run -v /home/workflow-demo/BlankFilter/data:/data log2transformation /data/output_batchfeatureremoval.xls /data/output_log2transformation.xls
```
