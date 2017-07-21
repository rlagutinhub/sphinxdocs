#! /bin/sh

set -e
set -x

# system
dnf -y --setopt=deltarpm=false --setopt=tsflags=nodocs install \
	bash-completion \
	less \
	wget \
	curl \
	pigz \
	which \
	tar \
	gzip \
	bzip2 \
	zip \
	unzip \
	findutils \
	util-linux \
	net-tools \
	iproute \
	bind-utils \
	at \
	cronie \
	crontabs \
	acl \
	attr \
	make \
	lsof \
	telnet \
	tree \
	nmap \
	tcpdump \
	mailx \
	htop \
	mc \
	vim-minimal vim-enhanced

# pip
dnf -y --setopt=deltarpm=false --setopt=tsflags=nodocs install python-setuptools python-pip

# apache httpd
dnf -y --setopt=deltarpm=false --setopt=tsflags=nodocs install \
	subversion \
	httpd \
	mod_ssl \
	mod_dav_svn

# texlive
dnf -y --setopt=deltarpm=false --setopt=tsflags=nodocs install \
	texlive \
	texlive-texlive-ru-doc \
	latexmk \
	texinfo

# texlive add-on
dnf -y --setopt=deltarpm=false --setopt=tsflags=nodocs install \
	texlive-needspace \
	texlive-capt-of \
	texlive-upquote \
	texlive-wrapfig \
	texlive-framed \
	texlive-tabulary \
	texlive-titlesec \
	texlive-fncychap

# texlive cyr
dnf -y --setopt=deltarpm=false --setopt=tsflags=nodocs install \
	texlive-lh \
	texlive-lcyw \
	texlive-cmcyr \
	texlive-lhcyr \
	texlive-xecyr \
	texlive-cyrillic \
	texlive-cmcyr-doc \
	texlive-xecyr-doc \
	texlive-cyrillic-bin \
	texlive-cyrillic-doc \
	texlive-cyrillic-bin-bin \
	texlive-collection-langcyrillic \
	texlive-context-cyrillicnumbers \
	texlive-context-cyrillicnumbers-doc

# texlive rus
dnf -y --setopt=deltarpm=false --setopt=tsflags=nodocs install \
	texlive-russ \
	texlive-russ-doc \
	texlive-datetime2-russian \
	texlive-datetime2-russian-doc \
	texlive-babel-russian \
	texlive-babel-russian-doc \
	texlive-hyphen-russian \
	texlive-ruhyphen \
	texlive-lshort-russian-doc
