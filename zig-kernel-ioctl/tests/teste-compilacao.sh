#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

SRC=/tmp/zigcalc_probe_integracao.zig
LOG=/tmp/zigcalc_compilacao_teste.log
EVIDENCIA=docs/evidencias/compilacao-provisoria.txt

cat > "$SRC" <<'ZIG'
pub export fn zigcalc_compute(
    operacao: c_int,
    a: c_int,
    b: c_int,
    resultado: *c_int,
) c_int {
    _ = operacao;
    _ = a;
    _ = b;
    _ = resultado;
    return 3;
}
ZIG

echo "Limpando compilacao anterior..."
make clean

echo "Compilando interface C..."
gcc -I kernel tests/teste-abi.c -o /tmp/zigcalc_teste_abi
/tmp/zigcalc_teste_abi

echo "Compilando modulo C + Zig provisório..."
if make ZIG_SRC="$SRC" > "$LOG" 2>&1; then
    cat "$LOG"
else
    cat "$LOG"
    echo "ERRO: compilacao falhou"
    exit 1
fi

test -f kernel/zigcalc.ko

if grep -q 'naked.*return' "$LOG"; then
    echo "ERRO: aviso de retorno encontrado"
    exit 1
fi

nm kernel/zigcalc.ko |
    grep -q ' T zigcalc_compute'

objdump -dr kernel/zigcalc_zig.o |
    grep -q '__x86_return_thunk'

{
    echo "TESTE DE COMPILACAO PROVISORIA"
    date -u
    echo
    echo "Kernel:"
    uname -r
    echo "Zig:"
    zig version
    echo "LLVM:"
    llc --version | head -n 2
    echo
    echo "Modulo gerado:"
    ls -lh kernel/zigcalc.ko
    echo
    echo "Simbolo Zig:"
    nm kernel/zigcalc.ko | grep zigcalc_compute
    echo
    echo "Mitigacao:"
    objdump -dr kernel/zigcalc_zig.o |
        grep __x86_return_thunk
    echo
    echo "Resultado: compilacao provisoria aprovada"
    echo "Operacoes matematicas: ainda nao testadas"
} > "$EVIDENCIA"

echo
echo "TESTE PROVISORIO APROVADO"
echo "Evidencia: $EVIDENCIA"
echo "Nao carregar este modulo no kernel."
