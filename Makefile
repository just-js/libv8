.PHONY: help clean

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_\.-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

v8lib: ## build v8 library
	docker build -t v8-build .
#	docker build -t v8-build-alpine -f Dockerfile.alpine .

v8deps: ## copy libs and includes from docker image
	rm -fr debian
	mkdir -p deps/v8
	mkdir -p debian
	docker run -dt --rm --name v8-build v8-build /bin/sh
	docker cp v8-build:/build/v8/out.gn/x64.release/obj/libv8_monolith.a debian/libv8_monolith.a
	docker cp v8-build:/build/v8/include deps/v8/
	docker kill v8-build
#	mkdir -p alpine
#	docker run -dt --rm --name v8-build-alpine v8-build-alpine /bin/sh
#	docker cp v8-build-alpine:/build/v8/out.gn/x64.release/obj/libv8_monolith.a alpine/libv8_monolith.a
#	docker kill v8-build-alpine

v8src: v8deps ## copy v8 source for ide integration
	docker run -dt --rm --name v8-build v8-build /bin/sh
	docker cp v8-build:/build/v8/src deps/v8/
	docker cp v8-build:/build/v8/out.gn/x64.release/gen deps/v8/
	docker kill v8-build

dist: deps ## make distribution package with v8 lib and headers
	cp -f debian/libv8_monolith.a deps/v8
	tar -cv deps | gzip --best > v8.tar.gz
#	cp -f alpine/libv8_monolith.a deps/v8
#	tar -cv deps | gzip --best > v8-alpine.tar.gz

dist-dev: v8deps v8src ## make distribution package with v8 lib headers and source
	make clean
	make v8deps
	make v8src
	tar -cv deps | gzip --best > v8src.tar.gz
	
clean: ## clean
	rm -fr deps
#	rm -f v8.tar.gz
#	rm -f v8-alpine.tar.gz

release: ## make release assets
	make clean
	make v8lib
	make v8deps
	make dist

.DEFAULT_GOAL := help
