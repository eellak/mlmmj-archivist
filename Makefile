# installation paths
SYSCONFDIR ?= $(DESTDIR)/etc/mlmmj-archivist
PREFIX     ?= $(DESTDIR)/usr/local
BINDIR     ?= $(PREFIX)/bin
SHAREDIR   ?= $(PREFIX)/share/mlmmj-archivist

all:
	cp mlmmj-archivist.sh mlmmj-archivist.sh.orig
	sed     -e "s:__SHAREDIR__:$(SHAREDIR):g" \
		-e "s:__SYSCONFDIR__:$(SYSCONFDIR):g" \
		mlmmj-archivist.sh.orig > mlmmj-archivist.sh
	cp config/mlmmj-archivist.conf.sample \
		config/mlmmj-archivist.conf.sample.orig
	sed     -e "s:__SHAREDIR__:$(SHAREDIR):g" \
		config/mlmmj-archivist.conf.sample.orig \
		> config/mlmmj-archivist.conf.sample

clean:
	test -f mlmmj-archivist.sh.orig && \
		mv mlmmj-archivist.sh.orig mlmmj-archivist.sh
	test -f config/mlmmj-archivist.conf.sample.orig && \
		mv config/mlmmj-archivist.conf.sample.orig \
		config/mlmmj-archivist.conf.sample

install: all
	for dir in $(BINDIR) $(SYSCONFDIR) $(SHAREDIR); \
		do test -d $$dir || install -d -m 0755 $$dir; \
	done
	install -m 0755 mlmmj-archivist.sh $(BINDIR)/mlmmj-archivist
	install -m 0644 config/mlmmj-archivist.conf.sample \
		$(SYSCONFDIR)/mlmmj-archivist.conf.sample
	install -m 0644 config/mhonarc.mrc.sample \
		$(SYSCONFDIR)/mhonarc.mrc.sample
	cp -r templates $(SHAREDIR)
	find $(SHAREDIR) -type d -exec chmod 755 {} \;
	find $(SHAREDIR) -type f -exec chmod 644 {} \;

.PHONY: all clean install
