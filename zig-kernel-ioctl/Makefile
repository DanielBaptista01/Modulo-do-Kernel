
# Projeto: zig-kernel-ioctl
# Integracao Zig 0.16.0 + Kernel Linux

KDIR := /lib/modules/$(shell uname -r)/build
MODDIR := $(CURDIR)/kernel

ZIG := zig
ZIG_SRC := kernel/zigcalc.zig
ZIG_OBJ := kernel/zigcalc_zig.o

.PHONY: all zig-object clean

# Compila o Zig e depois o modulo do kernel
all: zig-object
	$(MAKE) -C $(KDIR) M=$(MODDIR) modules

# Gera o objeto Zig sem depender da libc
zig-object:
	@test -f $(ZIG_SRC) || { \
		echo "Erro: arquivo $(ZIG_SRC) ainda nao existe."; \
		exit 1; \
	}
	$(ZIG) build-obj $(ZIG_SRC) \
		-target x86_64-freestanding \
		-O ReleaseFast \
		-fno-PIC \
		-mno-red-zone \
		-fno-stack-protector \
		-fno-stack-check \
		-fno-unwind-tables \
		-fno-error-tracing \
		-fno-compiler-rt \
		-femit-bin=$(ZIG_OBJ)

# Limpa os arquivos gerados
clean:
	$(MAKE) -C $(KDIR) M=$(MODDIR) clean
	rm -f $(ZIG_OBJ)
