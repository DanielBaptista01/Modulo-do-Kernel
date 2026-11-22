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

## Preparação do ambiente Alpine Linux

Este projeto foi desenvolvido em uma máquina virtual
Alpine Linux 3.24, arquitetura x86_64.

Instalar as ferramentas necessárias como root:

    apk update
    apk add build-base make llvm linux-virt-dev
    apk add strace kmod git linux-headers

O compilador Zig 0.16.0 deve ser instalado separadamente.

Verificar as ferramentas:

    zig version
    gcc --version
    llc --version
    make --version

Verificar o kernel e seus arquivos de desenvolvimento:

    uname -r
    ls -ld /lib/modules/$(uname -r)/build

A versão dos headers deve corresponder ao kernel
em execução. Na máquina utilizada, a versão validada foi:

    6.18.64-0-virt

Se houver incompatibilidade, alinhar os pacotes
linux-virt e linux-virt-dev antes de compilar.

A execução de módulos de kernel deve ocorrer
exclusivamente em máquina virtual de testes,
com snapshot e revisão de segurança prévios.

## Investigação técnica

O relatório apresenta a investigação da chamada
de sistema ioctl, das estruturas file_operations,
do registro miscdevice e dos mecanismos de
transferência de memória entre usuário e kernel.

O rastreamento completo da comunicação está em:

    docs/evidencias/strace-completo.txt

A atividade utiliza a syscall ioctl existente.
Nenhuma nova chamada de sistema foi criada.
