## Docker sphinxdocs (base image fedora:26)

Compiled Docker image: https://hub.docker.com/r/rlagutinhub/sphinxdocs/

-	Sphinx Documentation autoconfig with Apache SUBVERSION, Apapche HTTPD, LatexPDF. 
-	Use html_theme Read the Docs.

#### Manual install

```console
git clone https://github.com/rlagutinhub/sphinxdocs.git
cd sphinxdocs
```

Docker Image:

```console
docker build -t rlagutinhub/sphinxdocs:1 .
```

Docker network:

```console
docker network create -d bridge sphinxdocs_net-prod
```

Docker volume:

```console
docker volume create sphinxdocs_data-etc
docker volume create sphinxdocs_data-log
docker volume create sphinxdocs_data-www
```

Docker container:

```console
docker run -dit \
	-e "DATA_DIR=/var/www/html" \
	-e "SVN_NAME=docs.svn" \
	-e "SPHINX_NAME=docs.example" \
	-e "SPHINX_AUTHOR=author@example.com \
	-e "SPHINX_PDF_SCHED_M=0" \
	-e "SPHINX_PDF_SCHED_H=0" \
	-e "SVN_VHOST=svn.docs.example.com" \
	-e "SPHINX_VHOST=docs.example.com" \
	-e "AUTHZ_USERS=authz.users" \
	-e "AUTHZ_SVN=authz.svn" \
	-e "AUTHZ_USERS_ADMIN=admin" \
	-e "AUTHZ_USERS_ADMIN_PASS=1qaz@WSX" \
	-e "AUTHZ_USERS_DEVELOPER=developer" \
	-e "AUTHZ_USERS_DEVELOPER_PASS=1qaz@WSX" \
	-e "AUTHZ_USERS_READER=reader" \
	-e "AUTHZ_USERS_READER_PASS=1qaz@WSX" \
	--memory="2048m" --cpus=1 \
	--network=bridge -p 8080:80 \
	-v sphinxdocs_data-etc:/etc/httpd -v sphinxdocs_data-log:/var/log/httpd -v sphinxdocs_data-www:/var/www/html \
	--name sphinxdocs \
	rlagutinhub/sphinxdocs:1
```

Other:

```console
docker ps -a
docker container ls -a
docker image ls -a
docker exec -it sphinx01 bash (After complete work input: exit)
docker logs sphinx01
docker container stop sphinx01
docker container rm sphinx01
docker network rm sphinxdocs_net-prod
docker volume rm sphinxdocs_data-etc
docker volume rm sphinxdocs_data-log
docker volume rm sphinxdocs_data-www
docker image rm rlagutinhub/sphinxdocs:1
```

#### Auto install (docker-compose)

```console
pip install -U docker-compose
git clone https://github.com/rlagutinhub/sphinxdocs.git
cd sphinxdocs
```

```console
./start.sh
./stop.sh
./check-conf-yml.sh
```

Connect to container:

```console
./connect.sh
```
