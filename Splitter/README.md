#Splitter - Splits data according to sample names

In order to parallelize microservices, we need to split the data into the subsets that will be processed simultaneously. The Splitter divides the data based on the five first letters of the sample names (ignoring the "intensity_" in the beginning).

**Input:** Combined .xls file containing all samples

**Output:** Several .xls files named by the samples in the subset, at the stated location.
