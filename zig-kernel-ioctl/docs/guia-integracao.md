# Guia de integração e execução

## Preparação

Executar na pasta zig-kernel-ioctl.

Conferir:

    uname -r
    zig version
    llc --version
    ls -l /lib/modules/$(uname -r)/build

## Compilação definitiva

Quando kernel/zigcalc.zig estiver disponível:

    make clean
    make

O resultado esperado é kernel/zigcalc.ko.

## Compilação provisória

Para verificar somente a infraestrutura:

    sh tests/teste-compilacao.sh

O teste usa um arquivo Zig temporário que retorna
status INVALID. Ele não realiza cálculos.

## Interface Zig esperada

A função exportada deve ser compatível com:

    zigcalc_compute(
        operacao: c_int,
        a: c_int,
        b: c_int,
        resultado: *c_int
    ) c_int

Operações: 1 soma, 2 subtração, 3 multiplicação,
4 divisão.

Status: 0 OK, 1 divisão por zero, 2 overflow,
3 operação inválida.

## Segurança antes de carregar

Não executar insmod sobre o módulo provisório.

Antes de carregar a implementação final:

1. Criar snapshot da VM desligada.
2. Revisar o código Zig e os acessos a ponteiros.
3. Verificar uso de stack, runtime e símbolos externos.
4. Confirmar a mitigação de retorno no objeto final.
5. Verificar que não existem avisos relevantes do objtool.
6. Validar o módulo e sua compatibilidade com o kernel.

Somente depois dessas verificações realizar testes
controlados de carregamento, ioctl e remoção.

## Evidências

Arquivos da pasta docs/evidencias registram
informações do ambiente e testes de compilação.

Os testes funcionais devem ser adicionados após
a integração da calculadora definitiva.
