Well, not exactly. The main site (www subdomain) runs off Github Pages.

When working on a couple of server-based projects in the past year, I needed a
way of hosting them somewhere. I used EC2 to host my projects since I like to
have and full control over my instances, and whenever I would launch a project,
I would dedicate an EC2 instance to it. Of course, this does not scale; a micro
instance costs $0.02/hour or about $175/year. My projects also required few
resources and received little traffic, so dedicating an entire instance was
inefficient.

The solution was unbelievably obvious: use an actual web server. I chose to use
[nginx](http://www.nginx.org/); it's lightweight (great on a server with about
600 MB of memory) and simple to configure. But, being new to the whole web
server thing, I had some trouble getting started, so I decided to write this
post as a nginx guide for noobs.

## Use case

I use nginx primarily as a [reverse proxy
server](http://en.wikipedia.org/wiki/Reverse_proxy). Put simply, nginx acts as a
router. It takes requests from clients and forwards them to the proper servers,
while the client has no knowledge of the internal network. This allows me to set
up a few local servers, one per project, on one EC2 instance while still
providing simple public access.

In addition, I have my DNS set up so that "\*.danielge.org" and "\*.dge.io"
point to my EC2 instance. This allows me to quickly make updates to my
subdomains without having to wait for DNS changes to propagate, since all I have
to do is update my nginx configuration.

## Setting up nginx

There are two ways to do this: package manager and manual compilation. Because
nginx works with modules rather than plugins, you have to [specify the
modules](http://wiki.nginx.org/Modules) you want at compilation. Many Linux
distributions provide nginx packages with some modules already compiled in.
However, if you're interested in some of the [third-party
modules](http://wiki.nginx.org/3rdPartyModules), it would be worth knowing how
to compile nginx yourself. Regardless, you can find installation instructions on
the [nginx wiki](http://wiki.nginx.org/Install).

Once you get it set up, find the configuration file nginx.conf. It differs
depending on how you installed nginx. If you compiled it, you will find it in
/usr/local/nginx/conf.

## Configuring nginx

