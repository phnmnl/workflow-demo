FROM richarvey/nginx-php-fpm
MAINTAINER Anders Larsson, anders.larsson@icm.uu.se

# Copy local web into container
COPY html /usr/share/nginx/html

# env-var workaround script
COPY ./getenvs.sh /
RUN chmod 755 /getenvs.sh

# extended start script
COPY ./start_extended.sh /
RUN chmod 755 /start_extended.sh

ENTRYPOINT ["/start_extended.sh"]




