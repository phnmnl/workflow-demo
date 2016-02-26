# Plotting metabolomics LC/MS data

This tool has been developed using R to generate various plots for LC/MS data. The Docker image for this can be found "payamemami/plotmsdata"
Several arguments need to be provided to the tool:
 
```R
plotMSData.R -in=INPUTDATA -out=plotFileName -pattern=PatternToSelectColumns -impute=ImputeDataByZero(T or F) -plottype=typeOfPlot(BAR, BOX, PCA, THREE) -width=widthOfTheOutputImage(inch) -height=widthOfTheOutputImage(inch) -imagetype=imageFormat(JPG, PNG, PDF) -log=log2transformation(T or F)
```

## Arguments
 - in: Tab-separated input file
 - out: Name of the output file (with extension)
 - pattern: Common pattern to grep columns with intensities. if not provided, all columns are used
 - impute: Impute missing values by zero 
 - plottype: Plot type to generate (BAR=Barplot, BOX=Boxplot, PCA=Scatterplot of PCA scores, TREE=Hierarchical tree)
 - width: Width of the plot image in inch
 - Height: Height of the plot image in inch
 - imagetype: Image format (JPG, PNG or PDF)
 - log: Transform data to the log2 base scale
