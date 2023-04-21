# R2R - P2P CLI chat
![Built with ruby](https://img.shields.io/badge/built%20with-ruby-red)
![Ruby version 3.1.1](https://img.shields.io/badge/ruby%20version-3.1.3-brightgreen)

R2R is a P2P CLI chat built with Ruby using threads.

## Installation
Just run in tour terminal:
```
  bundle install
```

## Usage
To start as server:
```
  r2r -n [your identifier] -t server -p [port] 
```
To start as client:
```
  r2r -n [your identifier] -t client -p [port] -s [localhost/ip]
```

To send a message just press ctrl + n

To exit send a new message with !q as content

If starting as client and no server name (-s) provided, then localhost is used.

## Help

Run `r2r -h`:

```
  Usage: r2r -n [your identifier] -t [client/server] -p [port] -s [localhost/ip]

    -t, --type TYPE                  The type of the connection (client/server)
    -s, --server SERVER              [optional] Server to connect (only client), default:localhost,
                                     localhost or IP are accepted
    -p, --port PORT                  The port number
    -n, --name NAME                  The name of the user
    -v, --version                    Show version
```
