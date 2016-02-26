# Formating metabolomics LC/MS data (OpenMS)

This tool has been developed using R to format LC/MS data. The Docker image for this can be found "payamemami/converttodecyder"
Several arguments need to be provided to the tool:
 
```R
convert_to_decyder.R -in=TabSeparatedInputFile -out=OutputFolderPath -name=NameOfTheOutputFile
```

## Arguments
 - in: Tab-separated input file
 - out: Path of the output folder
 - name: Name of the output file
