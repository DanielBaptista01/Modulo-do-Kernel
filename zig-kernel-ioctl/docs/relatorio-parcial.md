# Relatório técnico — Módulo zigcalc

## 1. Objetivo

Desenvolver um módulo carregável do kernel Linux chamado
zigcalc.ko, utilizando um driver C e funções matemáticas em Zig.

A comunicação entre o espaço de usuário e o kernel é feita
pelo dispositivo /dev/zigcalc, por meio de chamadas ioctl.

## 2. Ambiente de desenvolvimento

- Sistema operacional: Alpine Linux 3.24.4
- Virtualização: Oracle VirtualBox
- Arquitetura: x86_64
- Kernel testado: Linux 6.18.64-0-virt
- Zig: 0.16.0
- LLVM: 22.1.3
- Ferramentas: GCC, Make, Git e Kbuild

A versão exata do kernel deve ser confirmada com uname -r.

## 3. Arquitetura

Componentes:

- kernel/zigcalc_ioctl.h: interface compartilhada
- kernel/zigcalc_glue.c: driver C e operações ioctl
- kernel/zigcalc.zig: implementação matemática em Zig
- kernel/Kbuild: regras de construção do módulo
- Makefile: comandos de compilação e limpeza
- client/: programa cliente, a integrar

Fluxo previsto:

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
zigcalc_compute() em Zig
    |
    v
Resultado ou código de erro

## 4. Interface ioctl

A estrutura zigcalc_request contém três inteiros
assinados de 32 bits:

- a: primeiro operando
- b: segundo operando
- resultado: resultado da operação

Seu tamanho esperado na arquitetura testada é 12 bytes.

Comandos:

- ZIGCALC_SOMA
- ZIGCALC_SUB
- ZIGCALC_MULT
- ZIGCALC_DIV

## 5. Tratamento de erros

O driver converte os status retornados por Zig:

- OK (0): operação concluída
- DIVZERO (1): -EDOM
- OVERFLOW (2): -ERANGE
- INVALID (3): -ENOTTY

Comando ioctl desconhecido retorna -ENOTTY.
Falhas de copy_from_user e copy_to_user retornam -EFAULT.

A implementação matemática definitiva ainda precisa
validar os casos extremos dos inteiros de 32 bits.

## 6. Registro do dispositivo

O driver utiliza misc_register para registrar um
miscdevice chamado zigcalc.

O dispositivo foi configurado com modo 0600,
limitando inicialmente o acesso ao proprietário.

A remoção utiliza misc_deregister.

## 7. Integração C + Zig

A função exportada pelo Zig segue a interface:

int zigcalc_compute(int operacao, int a, int b,
                    int *resultado);

O Kbuild combina zigcalc_glue.o e zigcalc_zig.o.

O Makefile principal delega a compilação ao Kbuild.

## 8. Integração com LLVM

O kernel utilizado habilita CONFIG_MITIGATION_RETHUNK.

Inicialmente, o Zig produziu uma instrução ret comum,
causando um aviso do objtool.

O fluxo de compilação foi adaptado para:

1. Gerar LLVM IR a partir de Zig.
2. Adicionar fn_ret_thunk_extern aos atributos de função.
3. Gerar o objeto com llc.
4. Integrar o objeto pelo Kbuild.

No teste provisório, o objeto passou a referenciar
__x86_return_thunk, sem o aviso anterior.

Essa verificação não substitui a análise de segurança
da implementação definitiva.

## 9. Resultados obtidos

Resultados já observados:

- Código C compilado
- Zig 0.16.0 compilado
- LLVM integrado ao Kbuild
- zigcalc.ko produzido com código Zig provisório
- Referência a __x86_return_thunk identificada
- Makefile principal testado

Esses resultados demonstram a construção do módulo,
não o funcionamento final das operações matemáticas.

## 10. Pendências

- Integrar kernel/zigcalc.zig definitivo
- Integrar cliente Zig
- Revisar ABI e dependências do código gerado
- Validar compatibilidade e segurança do módulo
- Criar snapshot da máquina virtual
- Carregar e remover o módulo com segurança
- Testar /dev/zigcalc e as quatro operações
- Testar divisão por zero e overflow
- Registrar evidências dos testes funcionais
- Finalizar conclusões e resultados da dupla
