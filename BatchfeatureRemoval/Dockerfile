FROM r-base
MAINTAINER Stephanie Herman, stephanie.herman.3820@student.uu.se

ADD BatchfeatureRemoval.r /

RUN echo '#!/bin/bash' > /usr/local/bin/BatchFeatureRemoval
RUN echo 'Rscript /BatchfeatureRemoval.r "$@"' >> /usr/local/bin/BatchFeatureRemoval
RUN chmod a+x /usr/local/bin/BatchFeatureRemoval

ENTRYPOINT ["Rscript", "BatchfeatureRemoval.r"] 
