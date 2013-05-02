all: compile

compile: site.hs
	ghc --make site.hs

build: compile
	./site build

preview: compile
	./site preview

clean:
	rm *.hi *.o
	rm -rf _site/
	rm -rf _cache/
