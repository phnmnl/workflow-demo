
# OpenMS Workflow
OpenMS is an open source platform for LC/MS data pre-processing and analysis. 
Several tools have been developed using OpenMS library including noise reduction, centroiding, quantification, and alignment. 

The following workflow has been developed to perform a simple LC/MS metabolomics data processing and analysis using OpenMS, Python, and R, utilizing the Docker containers concept. All the Docker images are available through [DockerHub](https://hub.docker.com/r/payamemami/) and the Docker files can be obtained through the [PhenoMeNal GitHub](https://github.com/phnmnl/workflow-demo). 

A typical LC/MC data processing consists of the following components:
- 
- Peak picking (centroiding)
- Feature Finding (quantification)
- Feature Linking (matching)
- Conversion (e.g. to tab-separated values files)
- Downstream Analysis

In the rest of this text, we will go through all the mentioned steps using OpenMS. For more information about specific tools please refer to [OpenMS documentation](http://ftp.mi.fu-berlin.de/pub/OpenMS/release-documentation/html/index.html). We will also use iPython within Jupyter notebook as the interface and R for downstream data analysis.


## Data prepration
Assuming you are in the root directory of Jupyter, we create a folder (named "OpenMS") and change the working directory to this folder.


```python
import os
workingDir="OpenMS"
if not os.path.exists(workingDir):
    os.makedirs(workingDir)
os.chdir(workingDir)
```

We then download two text files (called "data_list.txt" and "params.txt") where "data_list.txt" contains the names of the raw MS files (mzML) and download links for each of the files.
In addition, since OpenMS tools reads parameters as ".ini" files, we also need to download these files from the links provided in "params.txt".


```python
import urllib.request
urllib.request.urlretrieve("https://raw.githubusercontent.com/PayamE/Containers/master/data/data_list.txt","data_list.txt")
urllib.request.urlretrieve("https://raw.githubusercontent.com/PayamE/Containers/master/data/params.txt","params.txt")
```

Next, we create two folders ("rawFiles" and "paramFiles") and download the files using the links provided in "data_list.txt" and "params.txt" to their corresponding folders.


```python
import csv
import os
rawDirectory="rawFiles"
if not os.path.exists(rawDirectory):
    os.makedirs(rawDirectory)
paramDirectory="paramFiles"
if not os.path.exists(paramDirectory):
    os.makedirs(paramDirectory)
param_path=[]
with open('params.txt','r') as f:
    reader=csv.reader(f,delimiter='\t')
    for row in reader:
        urllib.request.urlretrieve(row[1],paramDirectory+"/"+row[0])
        param_path.append(row)
        

data_path=[]
with open('data_list.txt','r') as f:
    reader=csv.reader(f,delimiter='\t')
    for row in reader:
        urllib.request.urlretrieve(row[1],rawDirectory+"/"+row[0])
        data_path.append(row)
```

After that, we suppress possible warnings which might be issued due to insecure connection.


```python
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning) # suppress warnings
```

We input the address to the control node


```python
control=input()
```

as well as the password.


```python
import getpass
password=getpass.getpass()
```

Now we are ready to perform the first step of data pre-processing!
## Peak Picking and feature finding
Here we begin with peak picking which converts raw data into peak lists which will be used for further processing. We will then perform feature finding on the centrioded data (resulted from peak picking) to detect retention time and isotope. 


Briefly, for each raw data file, we prepare two "json" files. The first json ("json_peakpicker") will be used to spin up "PeakPickerHiRes" Docker container on a raw mzML file and the second json "(json_featurefinder") will be used for performing feature finding using "FeatureFinderMetabo" container on the result of PeakPickerHiRes. The most important difference in spin up method between PeakPickerHiRes and FeatureFinderMetabo is that FeatureFinderMetabo will be a dependent job, meaning that it will only run if "PeakPickerHiRes" has  successfully finished. So, a FeatureFinderMetabo container, set to work on file "X", will run if PeakPickerHiRes on the same file ("X") has finished. This means that a large number of PeakPickerHiRes-FeatureFinderMetabo pairs can be run at the same time.


```python
url_peakPicker="https://admin:"+password+"@"+control+"/chronos/scheduler/iso8601"
url_featureFinder="https://admin:"+password+"@"+control+"/chronos/scheduler/dependency"
i=0
containerNamesfeatureFinder=[]
featureFinderoutNames=[]
peakPickerDir="peakPickerDir"
featureFinderDir="featureFinderDir"
if not os.path.exists(peakPickerDir):
    os.makedirs(peakPickerDir)
if not os.path.exists(featureFinderDir):
    os.makedirs(featureFinderDir)
#2030-01-01T12:00:00Z
for mzFile in data_path:
    i=i+1
    peakPickerInputFile=mzFile[0]
    peakPickerOutputFile=mzFile[0]
    containerNamePeakPicker="peakpickerhires"+"_"+peakPickerInputFile.replace(".mzML","")
    json_peakpicker="""
    { 
        "schedule" : "R1//PT1H",  
        "cpus": "0.25",
        "mem": "100",  
        "epsilon" : "PT10M",  
        "name" : "%s",
        "container": {
            "type": "DOCKER",
            "image": "payamemami/peakpickerhires",
            "volumes": [{
                "hostPath": "/mnt/container-volumes/jupyter/%s",
                "containerPath": "/data",
                "mode": "RW"
             }]
        },
        "command" : "PeakPickerHiRes -in /data/%s/%s -out /data/%s/%s -ini /data/%s",
        "owner" : "payam.emami@medsci.uu.se"
    }
    """ % (containerNamePeakPicker,workingDir,rawDirectory,peakPickerInputFile,peakPickerDir ,peakPickerOutputFile, paramDirectory+"/peakPickerParam.ini")
    featureFinderoutput=peakPickerOutputFile.replace(".mzML",".featureXML")
    containerNamefeatureFinder="featurefindermetabo"+"_"+peakPickerOutputFile.replace(".mzML","")
    containerNamesfeatureFinder.append(containerNamefeatureFinder)
    featureFinderoutNames.append(featureFinderoutput)
    json_featurefinder="""
    { 
        "parents" : ["%s"],
        "cpus": "0.25",
        "mem": "100",  
        "epsilon" : "PT10M",  
        "name" : "%s",
        "container": {
            "type": "DOCKER",
            "image": "payamemami/featurefindermetabo",
            "volumes": [{
                "hostPath": "/mnt/container-volumes/jupyter/%s",
                "containerPath": "/data",
                "mode": "RW"
             }]
        },STAGING
        "command" : "FeatureFinderMetabo -in /data/%s/%s -out /data/%s/%s -ini /data/%s",
        "owner" : "payam.emami@medsci.uu.se"
    }
    """ % (containerNamePeakPicker,containerNamefeatureFinder,workingDir,peakPickerDir,peakPickerOutputFile,featureFinderDir ,featureFinderoutput,paramDirectory+"/featureFinderParam.ini")

    response=requests.post(url_peakPicker, headers = {'content-type' : 'application/json'}, data=json_peakpicker, verify=False)
    print("HTTP response code peakPicker: " + str(response.status_code))
    response=requests.post(url_featureFinder, headers = {'content-type' : 'application/json'}, data=json_featurefinder, verify=False)
    print("HTTP response code featureFinder: " + str(response.status_code))
```

## Feature linking
This process is used to match corresponding features across all the MS runs.
The method of spinning up is similar to that of feature finder. However, the container ("featurelinkerunlabeledqt") will be dependent on all of the FeatureFinderMetabo containers in the previous step. This means that "featurelinkerunlabeledqt" will only run if all the FeatureFinderMetabo processes successfully finish.


```python
featureLinkerDir="featureLinkerDir"
if not os.path.exists(featureLinkerDir):
    os.makedirs(featureLinkerDir)
url_featureLinker="https://admin:"+password+"@"+control+"/chronos/scheduler/dependency"
featureLinkerInput=' '.join(["/data/"+featureFinderDir+"/" + fileName for fileName in featureFinderoutNames])
featureLinkerOutput="featureLinkerResult.consensusXML"
containerNamefeatureLinker="featureLinker"
parents="%s"%(containerNamesfeatureFinder)
json_featureLinker="""
    { 
        "parents" : %s,
        "cpus": "0.25",
        "mem": "100",  
        "epsilon" : "PT10M",  
        "name" : "%s",
        "container": {
            "type": "DOCKER",
            "image": "payamemami/featurelinkerunlabeledqt",
            "volumes": [{
                "hostPath": "/mnt/container-volumes/jupyter/%s",
                "containerPath": "/data",
                "mode": "RW"
             }]
        },
        "command" : "FeatureLinkerUnlabeledQT -in %s -out /data/%s/%s -ini /data/%s",
        "owner" : "payam.emami@medsci.uu.se"
    }
    """ % (parents.replace("\'","\""),containerNamefeatureLinker,workingDir,featureLinkerInput,featureLinkerDir,featureLinkerOutput,paramDirectory+"/featureLinkerParam.ini")
response=requests.post(url_featureLinker, headers = {'content-type' : 'application/json'}, data=json_featureLinker, verify=False)
print("HTTP response code featureFinder: " + str(response.status_code))
```

## Exporting to CSV file
The consensusXML output of the linking process will be converted to a CSV file. This process is also dependent on the previous step.



```python
textExporterDir="textExporterDir"
if not os.path.exists(textExporterDir):
    os.makedirs(textExporterDir)
url_textExporter="https://admin:"+password+"@"+control+"/chronos/scheduler/dependency"
textExporterInput=featureLinkerDir+"/"+featureLinkerOutput
textExporterOutput="textExporterOutput.csv"
containerNameTextExporter="textexporter"
parents="%s"%(containerNamefeatureLinker)
json_textExporter="""
    { 
        "parents" : ["%s"],
        "cpus": "0.25",
        "mem": "100",  
        "epsilon" : "PT10M",  
        "name" : "%s",
        "container": {
            "type": "DOCKER",
            "image": "payamemami/textexporter",
            "volumes": [{
                "hostPath": "/mnt/container-volumes/jupyter/%s",
                "containerPath": "/data",
                "mode": "RW"
             }]
        },
        "command" : "TextExporter -in /data/%s -out /data/%s/%s -ini /data/%s",
        "owner" : "payam.emami@medsci.uu.se"
    }
    """ % (parents,containerNameTextExporter,workingDir,textExporterInput,textExporterDir,textExporterOutput,paramDirectory+"/textExporter.ini")
response=requests.post(url_textExporter, headers = {'content-type' : 'application/json'}, data=json_textExporter, verify=False)
print("HTTP response code featureFinder: " + str(response.status_code))
```

## Formatting the CSV file in R
The CSV file from the previous step is converted to an "Excel" like file. This step will only run if TextExporter has finished.


```python
convertToDecyderDir="convertToDecyderDir"
if not os.path.exists(convertToDecyderDir):
    os.makedirs(convertToDecyderDir)
url_convertToDecyder="https://admin:"+password+"@"+control+"/chronos/scheduler/dependency"
convertToDecyderInput=textExporterDir+"/"+textExporterOutput
convertToDecyderOutput=""
containerNameconvertToDecyder="converttodecyder"
textExporterOutputName="textExporterOutput.xls"
parents="%s"%(containerNameTextExporter)
json_textExporter="""
    { 
        "parents" : ["%s"],
        "cpus": "0.25",
        "mem": "100",  
        "epsilon" : "PT10M",  
        "name" : "%s",
        "container": {
            "type": "DOCKER",
            "image": "payamemami/converttodecyder",
            "volumes": [{
                "hostPath": "/mnt/container-volumes/jupyter/%s",
                "containerPath": "/data",
                "mode": "RW"
             }]
        },
        "command" : "Rscript convert_to_decyder.R -in=/data/%s -out=/data/%s -name=%s",
        "owner" : "payam.emami@medsci.uu.se"
    }
    """ % (parents,containerNameconvertToDecyder,workingDir,convertToDecyderInput,convertToDecyderDir,textExporterOutputName)
response=requests.post(url_textExporter, headers = {'content-type' : 'application/json'}, data=json_textExporter, verify=False)
print("HTTP response code featureFinder: " + str(response.status_code))
```

Using the formatted file, we plot the data using R functions from the ggplot package.


```python
plotDir="plotDir"
if not os.path.exists(plotDir):
    os.makedirs(plotDir)
url_plot="https://admin:"+password+"@"+control+"/chronos/scheduler/dependency"
plotInput=convertToDecyderDir+"/"+textExporterOutputName
plotOutput="plot.png"
containerNameplot="plotmsdata"
parents="%s"%(containerNameconvertToDecyder)
json_plot="""
    { 
        "parents" : ["%s"],
        "cpus": "0.25",
        "mem": "100",  
        "epsilon" : "PT10M",  
        "name" : "%s",
        "container": {
            "type": "DOCKER",
            "image": "payamemami/plotmsdata",
            "volumes": [{
                "hostPath": "/mnt/container-volumes/jupyter/%s",
                "containerPath": "/data",
                "mode": "RW"
             }]
        },
        "command" : "Rscript plotMSData.R -in=/data/%s -out=/data/%s/%s -pattern=intensity_ -impute=T -plottype=BOX -width=20 -height=20 -imagetype=PNG -log=T",
        "owner" : "payam.emami@medsci.uu.se"
    }
    """ % (parents,containerNameplot,workingDir,plotInput,plotDir,plotOutput)
response=requests.post(url_plotDir, headers = {'content-type' : 'application/json'}, data=json_plot, verify=False)
print("HTTP response code featureFinder: " + str(response.status_code))
```

Finally, we can see the plot!


```python
from IPython.display import Image
Image(filename=plotDir+"/"+plotOutput) 
```
