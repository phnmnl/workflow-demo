
## Phenomenal Service front webserver and home

Dockercontainer with NGINX php-enabled webserver containing service webpage

<strong>Input:</strong> bla

## Header 2

Text

```
$ docker build -t farmbio/frontweb .
```

```
$ docker run --name frontweb -e JUPYTER_HREF=http://www.bla.html -p 80:80 -d farmbio/frontweb
```

To run the service with local html files (development):

```
$ docker run --name frontweb -p 7777:80 -v ~/projekt/phenomenal/workflow-demo/frontweb/html:/usr/share/nginx/html:ro -d farmbio/frontweb
```




