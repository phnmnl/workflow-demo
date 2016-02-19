#FeatureSelection - Extract features with low CV

The FeatureSelection service extracts stable features based on the feature median CV.

**Input:** .xls file containing a matrix of CV:s, rows as features and a .xls file containging the samples as columns

**Output:** .xls file of samples containing only the extracted features

##Run FeatureSelection locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t featureselection .
```

To run the service you need to provide it with the name of your input and output files and you need to add a data volume to your image containging your input file. To add/create a volume you use the -v flag followed by the path/to/your/file:path/in/image

```
$ docker run -v /home/workflow-demo/data:/data featureselection /data/output_log2transformation.xls data/output_splitter/output_cv/output_merger.xls /data/output_featureselection.xls
```
