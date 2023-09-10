
PREFIX=/usr
UDEVLIBDIR=/usr/lib/udev
DRACUTLIBDIR=/usr/lib/dracut
INSTALL=install
# CFLAGS+=-O2 -Wall -g

all: make-bcache probe-bcache bcache-super-show bcache-register bcache

install: make-bcache probe-bcache bcache-super-show
	$(INSTALL) -m0755 make-bcache bcache-super-show	bcache $(DESTDIR)${PREFIX}/sbin/
	$(INSTALL) -m0755 bcache-status $(DESTDIR)${PREFIX}/sbin/
	$(INSTALL) -m0755 make-bcache bcache-super-show	bcache $(DESTDIR)${PREFIX}/bin/
	$(INSTALL) -d $(DESTDIR)$(UDEVLIBDIR)/
	$(INSTALL) -m0755 probe-bcache bcache-register bcache-export-cached $(DESTDIR)$(UDEVLIBDIR)/
	$(INSTALL) -d $(DESTDIR)$(UDEVLIBDIR)/rules.d/
	$(INSTALL) -m0644 69-bcache.rules	$(DESTDIR)$(UDEVLIBDIR)/rules.d/
	$(INSTALL) -d $(DESTDIR)${PREFIX}/share/man/man8/
	$(INSTALL) -m0644 -- *.8 $(DESTDIR)${PREFIX}/share/man/man8/
	$(INSTALL) -D -m0755 initramfs/hook	$(DESTDIR)/usr/share/initramfs-tools/hooks/bcache
	$(INSTALL) -D -m0755 initcpio/install	$(DESTDIR)/usr/lib/initcpio/install/bcache
	$(INSTALL) -D -m0755 dracut/module-setup.sh $(DESTDIR)$(DRACUTLIBDIR)/modules.d/90bcache/module-setup.sh
#	$(INSTALL) -m0755 bcache-test $(DESTDIR)${PREFIX}/sbin/

clean:
	$(RM) -f bcache make-bcache probe-bcache bcache-super-show bcache-register bcache-test -- *.o

bcache-test: LDLIBS += `pkg-config --libs openssl` -lm

make-bcache: LDLIBS += `pkg-config --libs uuid blkid`
make-bcache: CFLAGS += `pkg-config --cflags uuid blkid`
make-bcache: make.o crc64.o lib.o zoned.o

probe-bcache: LDLIBS += `pkg-config --libs uuid blkid`
probe-bcache: CFLAGS += `pkg-config --cflags uuid blkid`

bcache-super-show: LDLIBS += `pkg-config --libs uuid`
bcache-super-show: CFLAGS += -std=gnu99
bcache-super-show: crc64.o lib.o

bcache-register: bcache-register.o

bcache: CFLAGS += `pkg-config --cflags blkid uuid`
bcache: LDLIBS += `pkg-config --libs blkid uuid`
bcache: CFLAGS += -std=gnu99
bcache: crc64.o lib.o make.o zoned.o features.o show.o
