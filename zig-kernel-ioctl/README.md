# Calculadora Zig integrada ao Kernel Linux

Projeto desenvolvido para a disciplina de Sistemas Operacionais.

## Integrantes

- Daniel Santos Baptista
- Isaías de Oliveira

## Objetivo

Desenvolver um módulo carregável do kernel Linux que execute
operações matemáticas implementadas em Zig.

A comunicação entre o programa cliente e o módulo ocorre
por meio da chamada de sistema ioctl.

## Ambiente

- Alpine Linux 3.24
- Kernel Linux 6.18.64-0-virt
- Zig 0.16.0
- LLVM 22.1.3
- GCC 15.2.0

## Arquitetura

Cliente Zig
    |
    | ioctl
    v
/dev/zigcalc
    |
    v
Driver C (zigcalc_glue.c)
    |
    v
Função Zig (zigcalc_compute)
    |
    v
Resultado da operação

## Funcionalidades

- Soma
- Subtração
- Multiplicação
- Divisão
- Tratamento de divisão por zero
- Detecção de overflow
- Tratamento de comandos inválidos
- Testes de concorrência
- Tratamento de ponteiros inválidos (EFAULT)

## Compilação

Na pasta do projeto:

    make clean
    make

O módulo será gerado em:

    kernel/zigcalc.ko

Compilação do cliente:

    zig build-exe client/main.zig -lc -O ReleaseFast -femit-bin=zigcalc

## Execução

O módulo deve ser carregado apenas em uma máquina virtual
de testes, após snapshot e revisão de segurança.

Como root:

    insmod kernel/zigcalc.ko

Exemplos:

    ./zigcalc soma 10 20
    ./zigcalc sub 50 15
    ./zigcalc mult 7 8
    ./zigcalc div 100 4

Remoção:

    rmmod zigcalc

## Testes

Testes unitários:

    zig test --dep calc -Mroot=tests/math_test.zig -Mcalc=kernel/zigcalc.zig

Testes funcionais, com o módulo carregado, como root:

    sh tests/test.sh

Teste EFAULT:

    gcc -Wall -Wextra -O2 -Ikernel tests/teste-efault.c -o /tmp/teste-efault
    /tmp/teste-efault

## Resultados

- Cinco testes unitários aprovados.
- Operações matemáticas validadas.
- Tratamento de erros aprovado.
- Concorrência validada.
- EFAULT validado.
- Comunicação ioctl confirmada com strace.
- Compilação final sem avisos do objtool.
- Carregamento e remoção do módulo realizados com sucesso.

## Evidências

Os registros estão disponíveis em docs/evidencias/.

## Documentação

Relatório técnico: docs/relatorio.pdf
