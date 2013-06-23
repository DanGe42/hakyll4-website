---
title: Using nginx
---
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
600 MB of memory) and simple to configure (well, if you know what you are
doing). Since I was new to the whole server thing, I had trouble setting it up.

I decided to write a guide to help other newbies figure out what nginx is all
about. There's already a great intro guide that was recently posted on Hacker
News, [Nginx for Developers](http://carrot.is/coding/nginx_introduction); I
highly suggest that you check it out. The rest of this post will be a somewhat
higher-level guide to nginx, and how I use it.

## Use case

I use nginx primarily as a [reverse proxy
server](http://en.wikipedia.org/wiki/Reverse_proxy). Put simply, nginx acts as a
router. It takes requests from clients and forwards them to the proper servers,
while the client has no knowledge of the internal network. This allows me to set
up a few local servers, one per project, on one EC2 instance while still
providing simple public access.

In addition, I have my DNS set up so that "\*.danielge.org" and "\*.dge.io"
point to my EC2 instance. This allows me to quickly make updates to my
subdomains without having to resort to adding DNS entries (my old method), since
all I have to do is update my nginx configuration and restart nginx.

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

You will find a lot of configuration already specified for you in nginx.conf.
For the most part, you can probably [read up on what these options
do](http://wiki.nginx.org/Configuration#Reference) later on.

nginx is configured declaratively; in a way, it looks like CSS. Most of the
configuration related to actually serving HTTP will be found within the `http`
block that you should have in your file. To host multiple sites (very similar to
"virtual hosts" in the land of Apache) from my instance, we can add `server`
blocks in the `http` block.

For example, last year, I made a project that tracked participants in my college
house's scavenger hunt. I made it completely static after the hunt ended, since
it only required pulling old static data, and I placed the static HTML/CSS/JS in
a directory. Here's what the `server` block looks like:

~~~
server {
    listen  80;
    server_name kcech-hunt.danielge.org;

    root    /home/ubuntu/sites/kcech-hunt;
    index   index.html;
}
~~~

And now, you can access the old scavenger hunt by going to the domain
[kcech-hunt.danielge.org](http://kcech-hunt.danielge.org/).

For a slightly more complicated example, I currently host my
[iss-leaflet](https://github.com/DanGe42/iss-leaflet) on my instance. It's a
simple Node.js server running on port 9001 and only accessible from within my
instance. So, how do we server this to the outside world? We don't want to
necessarily expose port 9001 either; it's not very user-friendly. Instead, we
configure nginx to proxy to it.

~~~
server {
    listen  80;
    server_name iss.dge.io;

    location / {
        proxy_pass  http://localhost:9001;
        proxy_set_header    Host    $host;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
~~~

If you access [iss.dge.io](http://iss.dge.io/), nginx will forward you to the
local Node server, without you knowing anything about there being a separate
server. In fact, I could have set up a different EC2 instance altogether, used
that as the domain for the `proxy_pass` directive, and still make this proxying
hidden to the user.

As my final example, since I moved on to a new site, I want to avoid breaking
existing links to my old site while having www.danielge.org redirect to
www.dge.io. This is how I do it:

~~~
server {
    listen  80;
    server_name www.danielge.org;

    # Everything else will be directed to the old site
    location ~ "/\w+/.*" {
        return  301 $scheme://old.danielge.org$request_uri;
    }

    # Everything in the root will go to the new site
    location / {
        return  301 $scheme://dge.io/;
    }
}
~~~

## Conclusion

I hope this guide has been informative enough to show how and why one would use
nginx. If you have any feedback, feel free to send me an email (or message me on
Twitter).
