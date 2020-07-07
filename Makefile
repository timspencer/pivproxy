
default: .image secrets/server.crt

.image: Dockerfile proxy.conf
	docker build . -t timspencer/pivproxy:latest
	touch .image

secrets/server.crt:
	mkdir -p secrets
	openssl req -x509 -newkey rsa:4096 -keyout secrets/server.key -out secrets/server.crt -days 365 -nodes

run: default
	docker run -it -p 4443:4443 -e PROXY_URL=https://tspencer.lan/ -e PROXY_NAME=tspencer.lan -e PROXY_USERS=timothy.spencer@gsa.gov -v `pwd`/secrets:/secrets timspencer/pivproxy:latest

shell:
	docker run -it -p 4443:4443 -e PROXY_URL=https://tspencer.lan/ -e PROXY_NAME=tspencer.lan -e PROXY_USERS=timothy.spencer@gsa.gov -v `pwd`/secrets:/secrets timspencer/pivproxy:latest /bin/sh
