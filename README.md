# Módulo do Kernel Linux — Calculadora em Zig

Atividade avaliativa da disciplina **Sistemas Operacionais**, desenvolvida em dupla com **Zig 0.16.0** e **Alpine Linux**.

> **A versão oficial da entrega está na branch `zig-kernel-ioctl`, dentro da pasta `zig-kernel-ioctl/`.** A branch `main` contém esta página de apresentação e não é a branch exigida pelo enunciado.

## Acessar a entrega

- **[Abrir o projeto na branch de entrega](https://github.com/DanielBaptista01/Modulo-do-Kernel/tree/zig-kernel-ioctl/zig-kernel-ioctl)**
- [README completo: instalação, compilação, execução e testes](https://github.com/DanielBaptista01/Modulo-do-Kernel/blob/zig-kernel-ioctl/zig-kernel-ioctl/README.md)
- [Relatório técnico final (PDF)](https://github.com/DanielBaptista01/Modulo-do-Kernel/blob/zig-kernel-ioctl/zig-kernel-ioctl/docs/relatorio.pdf)
- [Evidências dos testes](https://github.com/DanielBaptista01/Modulo-do-Kernel/tree/zig-kernel-ioctl/zig-kernel-ioctl/docs/evidencias)
- [Código-fonte do módulo](https://github.com/DanielBaptista01/Modulo-do-Kernel/tree/zig-kernel-ioctl/zig-kernel-ioctl/kernel)
- [Código-fonte do cliente](https://github.com/DanielBaptista01/Modulo-do-Kernel/blob/zig-kernel-ioctl/zig-kernel-ioctl/client/main.zig)

## Como a entrega deve ser realizada

Conforme o enunciado, a entrega é realizada **no repositório GitHub utilizado na disciplina**, com:

1. **Branch obrigatória:** `zig-kernel-ioctl`.
2. **Diretório obrigatório:** `zig-kernel-ioctl/`.
3. **Arquivos exigidos:** código-fonte completo do módulo e do cliente, arquivos de compilação (Makefile/Kbuild), script de testes, README, relatório técnico em PDF e evidências.
4. **Reprodutibilidade:** as instruções e os arquivos devem permitir compilar e testar a solução na VM Alpine Linux.

**Link para informar ao professor:**

https://github.com/DanielBaptista01/Modulo-do-Kernel/tree/zig-kernel-ioctl

O enunciado não exige integrar a entrega à `main` nem especifica um formulário externo. Se houver um campo de envio na plataforma da disciplina, utilize nele o link da branch acima e siga eventuais orientações adicionais do professor.

## Visão geral da solução

O cliente **Zig 0.16.0** abre `/dev/zigcalc` e envia comandos pela chamada de sistema **`ioctl(2)`**. Uma camada mínima em C registra um dispositivo de caractere do tipo `miscdevice`, valida a transferência de dados com `copy_from_user()` e `copy_to_user()` e encaminha as operações à função `zigcalc_compute`, implementada em Zig e incorporada ao módulo `zigcalc.ko` pelo Kbuild/LLVM.

As operações executadas dentro do kernel são **soma, subtração, multiplicação e divisão inteira**, usando inteiros assinados de 32 bits. O projeto trata divisão por zero, overflow, comandos desconhecidos e ponteiros inválidos, sem criar uma nova syscall.

## Organização do projeto

```text
zig-kernel-ioctl/
├── README.md
├── Makefile
├── kernel/
│   ├── zigcalc.zig
│   ├── zigcalc_glue.c
│   ├── zigcalc_ioctl.h
│   └── Kbuild
├── client/
│   └── main.zig
├── tests/
│   ├── math_test.zig
│   ├── test.sh
│   └── teste-efault.c
└── docs/
    ├── relatorio.pdf
    └── evidencias/
        ├── compilacao-final.log
        ├── testes-finais.txt
        ├── strace-completo.txt
        ├── efault-final.txt
        └── dmesg-zigcalc.txt
```

## Ambiente de referência e reprodução

A solução foi validada em uma máquina virtual **Alpine Linux 3.24**, arquitetura x86_64, kernel **6.18.64-0-virt**, Zig **0.16.0**, LLVM **22.1.3** e GCC **15.2.0**. Os headers devem corresponder à versão do kernel em execução.

Para obter a versão de entrega:

```sh
git clone --branch zig-kernel-ioctl https://github.com/DanielBaptista01/Modulo-do-Kernel.git
cd Modulo-do-Kernel/zig-kernel-ioctl
```

Compilar e executar os testes unitários do código Zig:

```sh
zig test --dep calc -Mroot=tests/math_test.zig -Mcalc=kernel/zigcalc.zig
zig build-exe client/main.zig -lc -O ReleaseFast -femit-bin=zigcalc
make
```

**Segurança:** carregue `kernel/zigcalc.ko` com `insmod` apenas numa VM de testes, após snapshot e revisão do módulo. Com o dispositivo disponível, o script `sh tests/test.sh` é executado como root. As instruções completas estão no [README do projeto](https://github.com/DanielBaptista01/Modulo-do-Kernel/blob/zig-kernel-ioctl/zig-kernel-ioctl/README.md).

## Resultados documentados

Foram registrados cinco testes unitários aprovados, operações matemáticas, divisão por zero, overflow, comandos inválidos, execução simultânea de clientes, teste `EFAULT`, carregamento e remoção do módulo, além do rastreamento de `open`, `ioctl` e `close` pelo `strace`. O relatório apresenta a investigação sobre os mecanismos internos do kernel Linux e as dificuldades de integração entre Zig, LLVM e Kbuild.

## Integrantes

- Daniel Santos Baptista
- Isaías de Oliveira
