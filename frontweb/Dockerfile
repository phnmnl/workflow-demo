FROM richarvey/nginx-php-fpm

# Copy local web into container
COPY html /usr/share/nginx/html

# CMD set > /usr/share/nginx/html/envvar.txt

ADD ./getenvs.sh /getenvs.sh
RUN chmod 755 /getenvs.sh

CMD /getenvs.sh && /start.sh



