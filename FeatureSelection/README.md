#FeatureSelection - Extract features with low CV

The FeatureSelection service extracts stable features based on the feature median CV.

**Input:** .xls file containing a matrix of CV:s, rows as features and a .xls file containging the samples as columns

**Output:** .xls file of samples containing only the extracted features

##Run FeatureSelection locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t featureselection .
```

To run the service you need to provide it with the name of your input file (containing your samples as columns) and the name of a .xls file with CV values (one per feature). You also need to pass the name of the output file and add a data volume to your image containing your the two input files. In the example below the input data is located in the local folder *data* and a destination folder is created with the same name. 

```
$ docker run -v /home/workflow-demo/data:/data featureselection /data/input.xls data/input_cvs.xls /data/output.xls
```
