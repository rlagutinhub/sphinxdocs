#!/bin/bash

set -e
set -x

# VARIABLES

# $1 - $DATA_DIR
# $1 - $SVN_NAME
# $1 - $SPHINX_NAME
# $1 - $SPHINX_AUTHOR
# $1 - $SPHINX_PDF_SCHED_M
# $1 - $SPHINX_PDF_SCHED_H
# $1 - $SVN_VHOST
# $1 - $SPHINX_VHOST
# $1 - $AUTHZ_USERS
# $1 - $AUTHZ_SVN
# $1 - $AUTHZ_USERS_ADMIN
# $1 - $AUTHZ_USERS_ADMIN_PASS
# $1 - $AUTHZ_USERS_DEVELOPER
# $1 - $AUTHZ_USERS_DEVELOPER_PASS
# $1 - $AUTHZ_USERS_READER
# $1 - $AUTHZ_USERS_READER_PASS

FIRST_START_FLAG=".first_start_completed"

DATA_DIR=${DATA_DIR:-"/var/www/html"}

SVN_NAME=${SVN_NAME:-"docs.svn"}
SPHINX_NAME=${SPHINX_NAME:-"docs.example"}
SPHINX_AUTHOR=${SPHINX_AUTHOR:-"author@example.com"}

SPHINX_PDF_SCHED_M=${SPHINX_PDF_SCHED_M:-"0"}
SPHINX_PDF_SCHED_H=${SPHINX_PDF_SCHED_H:-"0"}

SVN_VHOST=${SVN_VHOST:-"svn.docs.example.com"}
SPHINX_VHOST=${SPHINX_VHOST:-"docs.example.com"}

AUTHZ_USERS=${AUTHZ_USERS:-"authz.users"}
AUTHZ_SVN=${AUTHZ_SVN:-"authz.svn"}

AUTHZ_USERS_ADMIN=${AUTHZ_USERS_ADMIN:-"admin"}
AUTHZ_USERS_ADMIN_PASS=${AUTHZ_USERS_ADMIN_PASS:-"1qaz@WSX"}
AUTHZ_USERS_DEVELOPER=${AUTHZ_USERS_DEVELOPER:-"developer"}
AUTHZ_USERS_DEVELOPER_PASS=${AUTHZ_USERS_DEVELOPER_PASS:-"1qaz@WSX"}
AUTHZ_USERS_READER=${AUTHZ_USERS_READER:-"reader"}
AUTHZ_USERS_READER_PASS=${AUTHZ_USERS_READER_PASS:-"1qaz@WSX"}

# FUNCTION

# $1 - the file in which to do the search/replace
function COMMENT_SED() {
	sed -i 's/^/#&/g' $1
}

# $1 - the setting/property to set
# $2 - the new value
# $3 - the path to xwiki.[cfg|properties]

function SET_SED() {
	sed -i s~"\#\? \?$1 \?=.*"~"$1 = $2"~g "$3"
}

# $1 - the text to search for
# $2 - the replacement text
# $3 - the file in which to do the search/replace
function REPLACE_SED() {
	sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# $1 - the text to search for
# $2 - the replacement text
# $3 - the file in which to do the search/replace
function APPEND_SED() {
	sed -i "/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/a $(echo $2 | sed -e 's/[\/&]/\\&/g')" $3
}

# $1 - $DATA_DIR
# $2 - $SPHINX_NAME
# $3 - $SPHINX_AUTHOR
# SPHINX_SETUP $DATA_DIR $SPHINX_NAME $SPHINX_AUTHOR
function SPHINX_SETUP() {

	if [ ! -d $1/$2 ]; then

		mkdir -p $1/$2; cd $1/$2
		$(which sphinx-quickstart) -q --sep -p "$2" -a "$3" -l "ru" --ext-mathjax --makefile --no-batchfile $1/$2
		
		local SPHINX_RTD_THEME_CSS=/usr/lib/python2.7/site-packages/sphinx_rtd_theme/static/css/theme.css
		
		cp -p $1/$2/source/conf.py $1/$2/source/conf.py.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
		cp -p $SPHINX_RTD_THEME_CSS $SPHINX_RTD_THEME_CSS.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
		
		REPLACE_SED "extensions = ['sphinx.ext.mathjax']" "extensions = [" $1/$2/source/conf.py
		APPEND_SED "extensions = [" "'sphinx.ext.mathjax'," $1/$2/source/conf.py
		APPEND_SED "'sphinx.ext.mathjax'," "'sphinx.ext.graphviz'," $1/$2/source/conf.py
		APPEND_SED "'sphinx.ext.graphviz'," "]" $1/$2/source/conf.py

		SET_SED "html_theme" "'sphinx_rtd_theme'" $1/$2/source/conf.py

		APPEND_SED "# Additional stuff for the LaTeX preamble." "'preamble': '\\usepackage[utf8]{inputenc}'," $1/$2/source/conf.py
		APPEND_SED "'preamble': '\\usepackage[utf8]{inputenc}'," "'babel': '\\usepackage[russian]{babel}'," $1/$2/source/conf.py
		APPEND_SED "'babel': '\\usepackage[russian]{babel}'," "'cmappkg': '\\usepackage{cmap}'," $1/$2/source/conf.py
		APPEND_SED "'cmappkg': '\\usepackage{cmap}'," "'fontenc': '\usepackage[T1,T2A]{fontenc}'," $1/$2/source/conf.py
		APPEND_SED "'fontenc': '\usepackage[T1,T2A]{fontenc}'," "'utf8extra':'\\DeclareUnicodeCharacter{00A0}{\\nobreakspace}'," $1/$2/source/conf.py
		
		REPLACE_SED "max-width:800px;" "" $SPHINX_RTD_THEME_CSS
		
		$(which make) html

	fi

}

# $1 - $DATA_DIR
# $2 - $SVN_NAME
# $3 - $SPHINX_NAME
# SVN_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME
function SVN_SETUP() {

	if [ ! -d $1/$2 ]; then

		mkdir -p $1; cd $1
		$(which svnadmin) create "$2"
		$(which svn) import -m "Initial repository" $1/$3/source/ file://$1/$2/source

		rm -rf $1/$3/source/*
		cd $1/$3
		$(which svn) checkout file://$1/$2/source

	fi

}

# $1 - $DATA_DIR
# $2 - $SVN_NAME
# $3 - $SPHINX_NAME
# $4 - $SVN_VHOST
# $5 - $SPHINX_VHOST
# $6 - $AUTHZ_USERS
# $7 - $AUTHZ_SVN
# HTTPD_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME $SVN_VHOST $SPHINX_VHOST $AUTHZ_USERS $AUTHZ_SVN
function HTTPD_SETUP() {

	if [ -f /etc/httpd/conf.d/ssl.conf ]; then
		mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	fi

	cp -p /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	COMMENT_SED /etc/httpd/conf.d/welcome.conf

	if [ -f /etc/httpd/conf.d/00-$5-vhost.conf ]; then
		mv -f /etc/httpd/conf.d/00-$5-vhost.conf /etc/httpd/conf.d/00-$5-vhost.conf.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	fi

cat <<EOF > /etc/httpd/conf.d/00-$5-vhost.conf
<VirtualHost *:80>
	ServerName $5
	#ServerAlias docs
	DocumentRoot "$1/$3/build/html"
	ErrorLog "logs/http_$5_error_log"
	CustomLog "logs/http_$5_access_log" combined
</VirtualHost>

<Directory "$1/$3/build/html">
	AuthType Basic
	AuthName "Private Area"
	AuthUserFile "$1/$6"
	Require valid-user
	AllowOverride all
	Options FollowSymLinks
	#Require all granted
</Directory>
EOF

	# sed -i -e "s|HTTPD_VHOST_SPHINX_TMPL|$HTTPD_VHOST_SPHINX|" /etc/httpd/conf.d/00-$HTTPD_VHOST_SPHINX-vhost.conf
	# sed -i -e "s|SPHINX_WORK_DIR_TMPL|$SPHINX_WORK_DIR|" /etc/httpd/conf.d/00-$HTTPD_VHOST_SPHINX-vhost.conf
	# sed -i -e "s|AUTHZ_USERS_TMPL|$AUTHZ_USERS|" /etc/httpd/conf.d/00-$HTTPD_VHOST_SPHINX-vhost.conf

	if [ -f /etc/httpd/conf.d/01-$4-vhost.conf ]; then
		mv -f /etc/httpd/conf.d/01-$4-vhost.conf /etc/httpd/conf.d/01-$4-vhost.conf.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	fi

cat <<EOF > /etc/httpd/conf.d/01-$4-vhost.conf
<VirtualHost *:80>
	ServerName $4
	#ServerAlias svn
	<Location />
		DAV svn
		SVNPath "$1/$2"
		AuthType Basic
		AuthName "Private Area"
		AuthUserFile "$1/$6"
		AuthzSVNAccessFile "$1/$7"
		Require valid-user
	</Location>
	ErrorLog "logs/http_$4_error_log"
	CustomLog "logs/http_$4_access_log" combined
</VirtualHost>

<Directory "$1/$2">
	AllowOverride all
	Options FollowSymLinks
	#Require all granted
</Directory>
EOF

	# sed -i -e "s|HTTPD_VHOST_SVN_TMPL|$HTTPD_VHOST_SVN|" /etc/httpd/conf.d/01-$HTTPD_VHOST_SVN-vhost.conf
	# sed -i -e "s|SVN_WORK_DIR-TMPL|$SVN_WORK_DIR|" /etc/httpd/conf.d/01-$HTTPD_VHOST_SVN-vhost.conf
	# sed -i -e "s|AUTHZ_USERS_TMPL|$AUTHZ_USERS|" /etc/httpd/conf.d/01-$HTTPD_VHOST_SVN-vhost.conf
	# sed -i -e "s|AUTHZ_USERS_SVN_TMPL|$AUTHZ_USERS_SVN|" /etc/httpd/conf.d/01-$HTTPD_VHOST_SVN-vhost.conf

}

# $1 - $DATA_DIR
# $2 - $AUTHZ_USERS
# $3 - $AUTHZ_USERS_ADMIN
# $4 - $AUTHZ_USERS_ADMIN_PASS
# $5 - $AUTHZ_USERS_DEVELOPER
# $6 - $AUTHZ_USERS_DEVELOPER_PASS
# $7 - $AUTHZ_USERS_READER
# $8 - $AUTHZ_USERS_READER_PASS
# AUTHZ_USERS_SETUP $DATA_DIR $AUTHZ_USERS $AUTHZ_USERS_ADMIN $AUTHZ_USERS_ADMIN_PASS $AUTHZ_USERS_DEVELOPER $AUTHZ_USERS_DEVELOPER_PASS $AUTHZ_USERS_READER $AUTHZ_USERS_READER_PASS
function AUTHZ_USERS_SETUP() {

	if [ -f $1/$2 ]; then
		mv -f $1/$2 $1/$2.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	fi

	$(which htpasswd) -bc $1/$2 $3 $4
	$(which htpasswd) -bm $1/$2 $5 $6
	$(which htpasswd) -bm $1/$2 $7 $8

}

# $1 - $DATA_DIR
# $2 - $SVN_NAME
# $3 - $AUTHZ_SVN
# $4 - $AUTHZ_USERS_ADMIN
# $5 - $AUTHZ_USERS_DEVELOPER
# $6 - $AUTHZ_USERS_READER
# AUTHZ_SVN_SETUP $DATA_DIR $SVN_NAME $AUTHZ_SVN $AUTHZ_USERS_ADMIN $AUTHZ_USERS_DEVELOPER $AUTHZ_USERS_READER
function AUTHZ_SVN_SETUP() {

	if [ -f $1/$3 ]; then
		mv -f $1/$3 $1/$3.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	fi

	cp -p $1/$2/conf/authz $1/$3
	COMMENT_SED $1/$3

cat <<EOF >> $1/$3
[groups]
admins = $4
developers = $5
readers = $6

[/]
@admins = rw
@developers = rw
@readers = r
* =
EOF

	# sed -i -e "s|AUTHZ_USERS_ADMIN_TMPL|$AUTHZ_USERS_ADMIN|" $AUTHZ_USERS_SVN
	# sed -i -e "s|AUTHZ_USERS_DEVELOPER_TMPL|$AUTHZ_USERS_DEVELOPER|" $AUTHZ_USERS_SVN
	# sed -i -e "s|AUTHZ_USERS_READER_TMPL|$AUTHZ_USERS_READER|" $AUTHZ_USERS_SVN

}

# $1 - $DATA_DIR
# $2 - $SVN_NAME
# $3 - $SPHINX_NAME
# HOOK_SVN_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME
function HOOK_SVN_SETUP() {

	if [ -f $1/$2/hooks/post-commit ]; then
		mv -f $1/$2/hooks/post-commit $1/$2/hooks/post-commit.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	fi

	cp -p $1/$2/hooks/post-commit.tmpl $1/$2/hooks/post-commit
	REPLACE_SED "^mailer.py" "#mailer.py" $1/$2/hooks/post-commit

cat <<EOF >> $1/$2/hooks/post-commit
cd $1/$3/source && /usr/bin/svn update
cd $1/$3 && /usr/bin/make html
EOF

}

# $1 - $DATA_DIR
# $2 - $SPHINX_NAME
# PDF_SETUP $DATA_DIR $SPHINX_NAME
function PDF_SETUP() {

	$(which fmtutil) --all
	cd $1/$2; $(which make) latexpdf; mv -f $1/$2/build/latex/${2//.}.pdf $1/$2/build/html/$2.pdf

}

# $1 - $DATA_DIR
# $2 - $SPHINX_NAME
# $3 - $SPHINX_PDF_SCHED_M
# $4 - $SPHINX_PDF_SCHED_H
# PDF_CRON_SETUP $DATA_DIR $SPHINX_NAME $SPHINX_PDF_SCHED_M $SPHINX_PDF_SCHED_H
function PDF_CRON_SETUP() {

	if [ -f /var/spool/cron/root ]; then
		mv -f /var/spool/cron/root /var/spool/cron/root.$(date +%Y-%m-%d.%H-%M-%S.%N).orig
	fi

	local PDF_CRON_SETUP_VAR_STR='cd '$1'/'$2' && '$(which make)' latexpdf && mv -f '$1'/'$2'/build/latex/'${2//.}'.pdf '$1'/'$2'/build/html/'$2'.pdf'
	crontab -l -u root 2>/dev/null | { cat; echo "$3 $4 * * * $PDF_CRON_SETUP_VAR_STR"; } | crontab -u root -

}

function CONFIGURE() {

	echo 'Configuring Sphinx-docs...'

	SPHINX_SETUP $DATA_DIR $SPHINX_NAME $SPHINX_AUTHOR
	SVN_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME
	HTTPD_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME $SVN_VHOST $SPHINX_VHOST $AUTHZ_USERS $AUTHZ_SVN
	AUTHZ_USERS_SETUP $DATA_DIR $AUTHZ_USERS $AUTHZ_USERS_ADMIN $AUTHZ_USERS_ADMIN_PASS $AUTHZ_USERS_DEVELOPER $AUTHZ_USERS_DEVELOPER_PASS $AUTHZ_USERS_READER $AUTHZ_USERS_READER_PASS
	AUTHZ_SVN_SETUP $DATA_DIR $SVN_NAME $AUTHZ_SVN $AUTHZ_USERS_ADMIN $AUTHZ_USERS_DEVELOPER $AUTHZ_USERS_READER
	HOOK_SVN_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME
	PDF_SETUP $DATA_DIR $SPHINX_NAME
	PDF_CRON_SETUP $DATA_DIR $SPHINX_NAME $SPHINX_PDF_SCHED_M $SPHINX_PDF_SCHED_H
	PERM_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME $AUTHZ_USERS $AUTHZ_SVN

}

# $1 - $DATA_DIR
# $2 - $SVN_NAME
# $3 - $SPHINX_NAME
# $4 - $AUTHZ_USERS
# $5 - $AUTHZ_SVN
# PERM_SETUP $DATA_DIR $SVN_NAME $SPHINX_NAME $AUTHZ_USERS $AUTHZ_SVN
function PERM_SETUP() {

	chown -R apache:apache $1/$2
	chown -R apache:apache $1/$3
	chown apache:apache $1/$4
	chown apache:apache $1/$5

}

# $1 - $DATA_DIR
# $2 - $FIRST_START_FLAG
function FIRST_START() {

	CONFIGURE; touch $1/$2

}

# MAIN
# https://github.com/docker-library/official-images#consistency
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#entrypoint
# https://github.com/CentOS/CentOS-Dockerfiles/tree/master/httpd/centos7

if [ "${1:0:1}" = '-' ]; then
	set -- supervisord "$@"
fi

if [ "$1" = 'supervisord' ]; then

	if [[ ! -f $DATA_DIR/$FIRST_START_FLAG ]]; then
		FIRST_START $DATA_DIR $FIRST_START_FLAG
	fi

	shift
	set -- "$(which supervisord)" "$@"

fi

exec "$@"



