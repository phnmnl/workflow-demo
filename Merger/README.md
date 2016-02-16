#Merger - Merges several files into one, columnwise

In order to parallelize microservices, we need to split the data into the subsets that will be processed simultaneously. This is done by the *Splitter* service. After the parallelized action of choice has been done, the results need to be further merged into a single file.

**Input:** Path to folder containing files to be merged

**Output:** A .xls file with the result files merged columnwise.
