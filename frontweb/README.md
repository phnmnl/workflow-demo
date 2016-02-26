
## Phenomenal Service Front Webserver and Home

This is a Dockercontainer with NGINX php-enabled webserver including the Phenomenal home webpages

Container is built from richarvey/nginx-php-fpm

Local web is copied into container webroot

Pass environment variable <code>JUPYTER_HREF</code> with link to Jupyter service

## Build
```
$ docker build -t farmbio/frontweb .
```

## Run
```
$ docker run --name frontweb -e JUPYTER_HREF=http://www.bla.html -p 80:80 -d farmbio/frontweb
```

## Run the service with local html files (development):

```
$ docker run --name frontweb -e JUPYTER_HREF=http://www.bla.html -p 7777:80 -v ~/projekt/phenomenal/workflow-demo/frontweb/html:/usr/share/nginx/html:ro -d farmbio/frontweb
```




