FROM r-base
MAINTAINER Stephanie Herman, stephanie.herman.3820@student.uu.se

ADD BlankFilter.r /

RUN echo '#!/bin/bash' > /usr/local/bin/BlankFilter
RUN echo 'Rscript /BlankFilter.r "$@"' >> /usr/local/bin/BlankFilter
RUN chmod a+x /usr/local/bin/BlankFilter 

ENTRYPOINT ["Rscript", "BlankFilter.r"] 
