run: secrets/server.crt docker-compose.yml
	docker-compose up

build: Dockerfile proxy.conf
	docker-compose build

secrets/server.crt:
	mkdir -p secrets
	openssl req -x509 -newkey rsa:4096 -keyout secrets/server.key -out secrets/server.crt -days 365 -nodes

