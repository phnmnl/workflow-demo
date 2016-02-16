#BlankFilter - Contaminants Removal

When perfoming any mass spectrometry (MS) study, it happens that you get plastic or other contaminent within your samples. When you furher analyse your samples with MS, these contaminant will be recorded together with the metabolites. To be able to detect and filter these out you often add blank samples (samples with only DMSO in them)  in between the normal samples in the runorder.

In this microservice we aim to remove the contaminants detected in the blanks, from the rest of our samples. The theory behind it is to remove everything that has an intensity of X in the blanks compared to the samples. For example, everything that, in the blanks, has an intensity of 1 % or higher of the intensities in the other samples.

**Input:** .xls file containing samples as columns

**Output:** A .xls file with contaminant filtered samples as columns
