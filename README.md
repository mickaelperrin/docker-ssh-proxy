ssh-proxy sets up a container running sshpiper and docker-gen generates reverse proxy configs for sshpiper and reloads sshpiper when containers are started and stopped.

This largely inspired by nginx-proxy of jwilder.

### Usage

To run it:

    $ docker run -d -p 2222:2222 -v /var/run/docker.sock:/tmp/docker.sock:ro mickaelperrin/ssh-proxy

Then start any containers you want proxied with an env var `SSH_PROXY_USER=myproxyuser` and an optional env var `SSH_REDIRECT_USER=foo`

The containers being proxied must [expose](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) the port to be proxied, either by using the `EXPOSE` directive in their `Dockerfile` or by using the `--expose` flag to `docker run` or `docker create`.

    $ docker run -e SSH_PROXY_USER=myproxyuser -e SSH_REDIRECT_USER=foo --expose=22 ...

### Docker Compose

```yaml
version: '2'

services:
  ssh-proxy:
    build: ../bundled
    ports:
      - 2222:2222
    networks:
      - sshproxy
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
    restart: unless-stopped

  sftp:
    command: foo:pass:1001
    depends_on:
      - ssh-proxy
    environment:
      - SSH_PROXY_USER=proxy
      - SSH_REDIRECT_USER=foo
    image: atmoz/sftp
    networks:
      - sshproxy
    volumes:
      - ./sftpdir:/home/foo

networks:
  sshproxy:
```

```shell
$ docker-compose up
$ sftp -P 2222 proxy@127.0.0.1:testfile.txt
```

### Default User

The ENV variable `SSH_REDIRECT_USER` can be omitted and will be defaulted to the value of `SSH_PROXY_USER`

### Separate Containers

ssh-proxy can also be run as two separate containers using the [jwilder/docker-gen](https://index.docker.io/u/jwilder/docker-gen/) image and the separated image.

You may want to do this to prevent having the docker socket bound to a publicly exposed container service.

You can demo this pattern with docker-compose:

```console
$ docker-compose --file example/docker-compose.proxy-separated.yml up
$ docker-compose --file example/docker-compose.yml up
$ sftp -P 2222 proxy@127.0.0.1:testfile.txt
```

To run ssh-proxy as a separate container you'll need to have sshproxy.tmpl file on your host system or use the dockergen version with in in dockergen folder.

First create a network:

    $ docker create network ssh-proxy

Then start sshpiper:

    $ docker run -d -p 2222:2222 --name ssh-proxy --net ssh-proxy -t mickaelperrin/ssh-proxy-alone 

Then start the docker-gen container with the template:

```
$ docker run --volumes-from ssh-proxy \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -v $(pwd)/dockergen/sshproxy.tmpl:/etc/docker-gen/templates/sshproxy.tmpl \
    -t jwilder/docker-gen -watch /etc/docker-gen/templates/sshproxy.tmpl /etc/sshpiper/docker.generated.conf 
```

Finally, start your containers with `SSH_PROXY_USER` environment variables.

    $ docker run -e SSH_PROXY_USER=proxy  ...
    
### Contributing

Before submitting pull requests or issues, please check github to make sure an existing issue or pull request is not already open.

### Acknowledgement

Thanks a lot to :

- jwilder for his awesome docker-gen and nginx-proxy tools
- tg123 for his awesome ssh proxy tool

