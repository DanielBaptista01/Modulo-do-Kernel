# Projeto: zig-kernel-ioctl
# Integracao Zig 0.16.0 + LLVM + Kernel Linux

KDIR := /lib/modules/$(shell uname -r)/build
MODDIR := $(CURDIR)/kernel

ZIG ?= zig
LLC ?= llc
ZIG_SRC ?= $(MODDIR)/zigcalc.zig

.PHONY: all clean

# Usa > como prefixo dos comandos para evitar problemas com TAB
.RECIPEPREFIX := >

all:
> @test -f "$(ZIG_SRC)" || { echo "Erro: arquivo Zig nao encontrado: $(ZIG_SRC)"; exit 1; }
> $(MAKE) -C "$(KDIR)" M="$(MODDIR)" ZIG="$(ZIG)" LLC="$(LLC)" ZIG_SRC="$(ZIG_SRC)" modules

clean:
> $(MAKE) -C "$(KDIR)" M="$(MODDIR)" clean
> rm -f "$(MODDIR)/zigcalc_zig.ll" "$(MODDIR)/zigcalc_zig_rethunk.ll" "$(MODDIR)/zigcalc_zig_raw.tmp"
