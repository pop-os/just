TARGET = debug
DEBUG ?= 0

BIN=$(DESTDIR)/usr/bin/just
COMP_BASH=$(DESTDIR)/usr/share/bash-completion/completions/just
COMP_FISH=$(DESTDIR)/usr/share/fish/vendor_completions.d/just.fish
COMP_ZSH=$(DESTDIR)/usr/share/zsh/vendor-completions/_just

.PHONY = all clean install uninstall vendor

ifeq ($(DEBUG),0)
	TARGET = release
	ARGS += --release
endif

VENDOR ?= 0
ifneq ($(VENDOR),0)
	ARGS += --frozen --offline
endif

all: extract-vendor
	cargo build $(ARGS)

clean:
	cargo clean

distclean:
	rm -rf .cargo vendor vendor.tar target

vendor:
	mkdir -p .cargo
	cargo vendor | head -n -1 > .cargo/config
	echo 'directory = "vendor"' >> .cargo/config
	tar pcf vendor.tar vendor
	rm -rf vendor

extract-vendor:
ifeq ($(VENDOR),1)
	rm -rf vendor; tar pxf vendor.tar
endif

install:
	install -Dm0755 target/$(TARGET)/just $(BIN)
	install -Dm0644 completions/just.bash $(COMP_BASH)
	install -Dm0644 completions/just.fish $(COMP_FISH)
	install -Dm0644 completions/just.zsh $(COMP_ZSH)
