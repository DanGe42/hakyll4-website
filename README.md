About
=====

This is the code behind my personal website. It uses
[Hakyll](http://jaspervdj.be/hakyll/), a static site generator written in
Haskell, to generate the HTML/CSS/JavaScript that gets uploaded to the [Github
Page](https://github.com/DanGe42/DanGe42.github.io).

Check out my site at either [dge.io](http://dge.io) or
[dange42.github.io](http://dange42.github.io).

How to run
==========

Make sure you get the dependencies installed.

* Haskell
* Hakyll (>= 4) (`cabal install hakyll`)

Once you clone my repository, simply run `make` to compile site.hs. `make build`
will generate the site into the \_site/ folder, and `make preview` will allow
you to access the site at `localhost:8000`.
