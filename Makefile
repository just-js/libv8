.PHONY: help clean

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_\.-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

v8lib: ## build v8 library
	docker build -t v8-build .

v8deps: ## copy libs and includes from docker image
	mkdir -p deps/v8
	docker run -dt --rm --name v8-build v8-build /bin/sh
	docker cp v8-build:/build/v8/out.gn/x64.release/obj/libv8_monolith.a deps/v8/libv8_monolith.a
	docker cp v8-build:/build/v8/include deps/v8/
	docker kill v8-build

v8src: v8deps ## copy v8 source for ide integration
	docker run -dt --rm --name v8-build v8-build /bin/sh
	docker cp v8-build:/build/v8/src deps/v8/
	docker cp v8-build:/build/v8/out.gn/x64.release/gen deps/v8/
	docker kill v8-build

dist: v8deps ## make distribution package with v8 lib and headers
	make clean
	make v8deps
	tar -cv deps | gzip --best > v8.tar.gz

dist-dev: v8deps v8src ## make distribution package with v8 lib headers and source
	make clean
	make v8deps
	make v8src
	tar -cv deps | gzip --best > v8src.tar.gz
	
clean: ## clean
	rm -fr deps

.DEFAULT_GOAL := help
