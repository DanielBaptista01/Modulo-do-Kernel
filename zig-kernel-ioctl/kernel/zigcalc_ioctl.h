
#ifndef ZIGCALC_IOCTL_H
#define ZIGCALC_IOCTL_H

#include <linux/ioctl.h>
#include <linux/types.h>

/* Estrutura compartilhada entre cliente e kernel */
struct zigcalc_request {
    __s32 a;
    __s32 b;
    __s32 resultado;
};

/* Identificador dos comandos ioctl */
#define ZIGCALC_MAGIC 'Z'

#define ZIGCALC_SOMA _IOWR(ZIGCALC_MAGIC, 1, struct zigcalc_request)
#define ZIGCALC_SUB  _IOWR(ZIGCALC_MAGIC, 2, struct zigcalc_request)
#define ZIGCALC_MULT _IOWR(ZIGCALC_MAGIC, 3, struct zigcalc_request)
#define ZIGCALC_DIV  _IOWR(ZIGCALC_MAGIC, 4, struct zigcalc_request)

/* Identificadores das operações matemáticas */
#define ZIGCALC_OP_SOMA 1
#define ZIGCALC_OP_SUB  2
#define ZIGCALC_OP_MULT 3
#define ZIGCALC_OP_DIV  4

/* Status retornados pelas funções Zig */
#define ZIGCALC_STATUS_OK       0
#define ZIGCALC_STATUS_DIVZERO  1
#define ZIGCALC_STATUS_OVERFLOW 2
#define ZIGCALC_STATUS_INVALID  3

#endif
