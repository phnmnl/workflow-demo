
## Phenomenal Service front webserver and home

Dockercontainer with NGINX php-enabled webserver containing service webpage

<strong>Input:</strong> bla

## Header 2

Text

```
$ docker build -t frontweb .
```

```
$ docker run --name frontweb -p 7777:80 -d frontweb
```

To run the service with local html files (debug/development):

```
$ docker run --name frontweb -p 7777:80 -v ~/projekt/docker/frontweb/html:/usr/share/nginx/html:ro -d frontweb
```




