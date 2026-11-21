#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

if [ "$(id -u)" -ne 0 ]; then
    echo "Execute com sudo sh tests/test.sh"
    exit 1
fi

if [ ! -e /dev/zigcalc ]; then
    echo "ERRO: /dev/zigcalc nao encontrado"
    exit 1
fi

if [ ! -x ./zigcalc ]; then
    echo "ERRO: cliente zigcalc nao compilado"
    exit 1
fi

ok() {
    esperado="$1"
    shift

    saida=$("$@" 2>&1) || {
        echo "FALHOU: $*"
        echo "$saida"
        exit 1
    }

    echo "$saida"
    printf '%s\n' "$saida" | grep -Fq "$esperado"
}

erro() {
    esperado="$1"
    shift

    if saida=$("$@" 2>&1); then
        echo "FALHOU: deveria retornar erro: $*"
        exit 1
    fi

    echo "$saida"
    printf '%s\n' "$saida" | grep -Fq "$esperado"
}

echo "=== Operacoes validas ==="
ok "Resultado: 30" ./zigcalc soma 10 20
ok "Resultado: 35" ./zigcalc sub 50 15
ok "Resultado: 56" ./zigcalc mult 7 8
ok "Resultado: 25" ./zigcalc div 100 4
ok "Resultado: -3" ./zigcalc div -7 2

echo "=== Tratamento de erros ==="
erro "divisao por zero" ./zigcalc div 10 0
erro "overflow" ./zigcalc soma 2147483647 1
erro "overflow" ./zigcalc sub -2147483648 1
erro "overflow" ./zigcalc mult 2147483647 2
erro "overflow" ./zigcalc div -2147483648 -1
erro "comando desconhecido" ./zigcalc desconhecido 1 2
erro "operando invalido" ./zigcalc soma abc 10

echo "=== Execucao simultanea ==="
./zigcalc soma 20 30 > /tmp/zigcalc-1.txt &
p1=$!

./zigcalc mult 6 7 > /tmp/zigcalc-2.txt &
p2=$!

./zigcalc div 144 12 > /tmp/zigcalc-3.txt &
p3=$!

wait "$p1"
wait "$p2"
wait "$p3"

grep -Fq "Resultado: 50" /tmp/zigcalc-1.txt
grep -Fq "Resultado: 42" /tmp/zigcalc-2.txt
grep -Fq "Resultado: 12" /tmp/zigcalc-3.txt

echo "Concorrencia: OK"
echo "TODOS OS TESTES FUNCIONAIS PASSARAM"
