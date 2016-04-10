# Spring Docker Example

This repository provides an example of how to work with
[Spring](https://github.com/rails/spring/) while running a [Ruby on
Rails](http://rubyonrails.org/) application inside a
[Docker](https://www.docker.com/) container. Support for this workflow
has been added in Spring 1.7.

The aim was to be able to have Spring installed on your development
host, but have everything else to do with your application running
inside Docker containers.

## Demo

1. Install Docker and [Docker Compose](https://docs.docker.com/compose/)
2. Build the containers: `$ docker-compose build`
3. Install Spring on your development host (version must match the
   `Gemfile.lock`): `$ gem install spring --version=1.7.0`
4. Run something: `$ bin/rails c` (this will bring up the Docker container
   which runs the spring server, and then connect to it)

## How it works

The [`Dockerfile`](Dockerfile) contains a [fairly
standard](https://docs.docker.com/compose/rails/) setup for a Rails
application under Docker, although it is necessary to make sure that
the UIDs on the host and inside the container are matching, to ensure
that Spring's socket file can be accessed on both sides.

The [`docker-compose.yml`](docker-compose.yml) file defines a standard
`web` container which runs your web server. It also defines a `spring`
container which runs the spring server.

In order for the spring client on the development host to communicate
with the spring server inside the container, we need to set some
environment variables:

* `SPRING_SOCKET=tmp/spring.sock`: defines a fixed location for the
  Spring socket file, so that it can be found both inside and outside
  the container (inside the container it is at `/app/tmp/spring.sock`
  and outside it is at `/path/to/spring-docker-example/tmp/spring.sock`)
* `SPRING_SERVER_COMMAND='docker-compose up spring'`: defines what we
  need to run to bring up the spring server when it is not already
  running. When we first run `bin/rails c`, Spring will detect
  that there isn't already a server running, and run this command.

There are obviously various ways to set these environment variables (I
like [direnv](https://github.com/direnv/direnv)) but for simplicity
we're setting them in
[`config/spring_client.rb`](config/spring_client.rb) which will be
automatically loaded by Spring.

## Mac OS X support

I use Linux, which means that my development machine is also my Docker
host (there is no intermediate virtual machine). The Spring socket file
is shared beetween the host and the container via a Dockers shared
volume.

On OS X you'll be using [Docker
Machine](https://docs.docker.com/machine/) or possibly [the beta of
Docker for
Mac](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/).

Either way, the Docker host will be a virtual machine. So the socket
file will be shared with the virtual machine via a Docker shared volume,
but you'll need to figure out some way to further share it from the
virtual machine to your OS X host.

This should be possible but I don't know exactly how. If anybody figures
out how to make this work, please submit a pull request to update this
documentation.

## PID namespace

The `spring stop` and `spring status` commands rely on being able to
have direct access to the spring server process. We set `pid: host`
([see
docs](https://docs.docker.com/engine/reference/run/#pid-settings-pid))
in [docker-compose.yml](docker-compose.yml) to achieve this, but it will
only work if your Docker host is also your development machine (i.e. if
you're using Linux).

Actually *running* Spring commands will work regardless of the PID
namespace, since this happens purely via communication over the socket.

In theory, `spring stop` and `spring status` could be modified to
communicate over the socket too, thus removing this limitation. However
it's not something I'm working on.
