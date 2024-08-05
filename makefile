build:
	docker build --build-arg BASE_VERSION=0.1.6 --target rest . -t ghcr.io/jodconverter/jodconverter-examples:rest

start-rest: stop
	docker run --name jodconverter-rest -m 512m --rm -p 8080:8080 ghcr.io/jodconverter/jodconverter-examples:rest

stop:
	docker stop --name jodconverter-rest > /dev/null 2>&1 || true
