
# vendor="Lagutin R.A."
# maintainer="Lagutin R.A. <rlagutin@mta4.ru>"
# name="Sphinx Documentation."
# description="Sphinx Documentation autoconfig with Apache SUBVERSION, Apapche HTTPD, LatexPDF. Use theme Read the Docs."
# version="v.1-prod."
# release-date="2017-07-21"

# ---------------------------------------------------------------------------

# Docker Image:
# docker build -t rlagutinhub/sphinxdocs:1 .

# Docker network:
# docker network create -d bridge sphinxdocs_net-prod

# Docker volume:
# docker volume create sphinxdocs_data-etc
# docker volume create sphinxdocs_data-log
# docker volume create sphinxdocs_data-www

# Docker container:
# docker run -dit \
# -e "DATA_DIR=/var/www/html" \
# -e "SVN_NAME=docs.svn" \
# -e "SPHINX_NAME=docs.example" \
# -e "SPHINX_AUTHOR=author@example.com \
# -e "SPHINX_PDF_SCHED_M=0" \
# -e "SPHINX_PDF_SCHED_H=0" \
# -e "SVN_VHOST=svn.docs.example.com" \
# -e "SPHINX_VHOST=docs.example.com" \
# -e "AUTHZ_USERS=authz.users" \
# -e "AUTHZ_SVN=authz.svn" \
# -e "AUTHZ_USERS_ADMIN=admin" \
# -e "AUTHZ_USERS_ADMIN_PASS=1qaz@WSX" \
# -e "AUTHZ_USERS_DEVELOPER=developer" \
# -e "AUTHZ_USERS_DEVELOPER_PASS=1qaz@WSX" \
# -e "AUTHZ_USERS_READER=reader" \
# -e "AUTHZ_USERS_READER_PASS=1qaz@WSX" \
# --memory="2048m" --cpus=1 \
# --network=bridge -p 8080:80 \
# -v sphinxdocs_data-etc:/etc/httpd -v sphinxdocs_data-log:/var/log/httpd -v sphinxdocs_data-www:/var/www/html \
# --name sphinxdocs \
# rlagutinhub/sphinxdocs:1

# Other:
# docker ps -a
# docker container ls -a
# docker image ls -a
# docker exec -it sphinx01 bash (After complete work input: exit)
# docker logs sphinx01
# docker container stop sphinx01
# docker container rm sphinx01
# docker network rm sphinxdocs_net-prod
# docker volume rm sphinxdocs_data-etc
# docker volume rm sphinxdocs_data-log
# docker volume rm sphinxdocs_data-www
# docker image rm rlagutinhub/sphinxdocs:1

# ---------------------------------------------------------------------------

#FROM centos:latest # problem latex cyrillic lang packages
FROM fedora:latest

LABEL rlagutinhub.community.vendor="Lagutin R.A." \
	rlagutinhub.community.maintainer="Lagutin R.A. <rlagutin@mta4.ru>" \
	rlagutinhub.community.name="Sphinx Documentation." \
	rlagutinhub.community.description="Sphinx Documentation autoconfig with Apache SUBVERSION, Apapche HTTPD, LatexPDF. Use theme Read the Docs." \
	rlagutinhub.community.version="v.1-prod." \
	rlagutinhub.community.release-date="2017-07-21"

COPY build /tmp/build

RUN chmod -x /tmp/build/supervisord.conf && mv -f /tmp/build/supervisord.conf /etc/supervisord.conf && \
	chmod +x /tmp/build/* && mv -f /tmp/build/bash-color.sh /etc/profile.d/bash-color.sh && mv -f /tmp/build/docker-entrypoint.sh /etc/docker-entrypoint.sh && \
	for script in /tmp/build/*.sh; do sh $script; done && \
	rm -rf /tmp/build

# EXPOSE 80 443
EXPOSE 80

ENTRYPOINT ["/etc/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

