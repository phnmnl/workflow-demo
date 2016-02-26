#BlankFilter - Contaminants Removal

When perfoming any mass spectrometry (MS) study, it happens that you get plastic or other contaminent within your samples. When you furher analyse your samples with MS, these contaminant will be recorded together with the metabolites. To be able to detect and filter these out you often add blank samples (samples with only DMSO in them)  in between the normal samples in the runorder.

In this microservice we aim to remove the contaminants detected in the blanks, from the rest of our samples. The theory behind it is to remove everything that has an intensity of X in the blanks compared to the samples. For example, everything that, in the blanks, has an intensity of 1 % or higher of the intensities in the other samples.

**Input:** .xls file containing samples as columns

**Output:** A .xls file with contaminant filtered samples as columns

##Run Blankfilter locally

Build your image, using the following command. Use the -t flag to tag it with any desired name.

```
$ docker build -t blankfilter .
```
To run the service you need to provide it with the names of your input and output files and you need to add a data volume to your image containing your input file. In the example below the input data is located in the local folder *data* and a destination folder is created with the same name. 

```
$ docker run -v /home/workflow-demo/BlankFilter/data:/data blankfilter /data/inputdata.xls /data/output.xls
```
