#BatchfeatureRemoval - Removal of batch specific features

In MS studies you may, if you have many samples, prepare the samples in batches. By doing so you introduce a risk of having features that are unique within a batch, which is not desirable. 

The task of this microservice is to remove features that have a coverage of 80% within one batch, but not in any other. Put in other words, remove batch specific features.
