FROM r-base
MAINTAINER Stephanie Herman, stephanie.herman.3820@student.uu.se

ADD log2transformation.r /

RUN echo '#!/bin/bash' > /usr/local/bin/log2transformation
RUN echo 'Rscript /log2transformation.r "$@"' >> /usr/local/bin/log2transformation
RUN chmod a+x /usr/local/bin/log2transformation

ENTRYPOINT ["Rscript", "log2transformation.r"] 
