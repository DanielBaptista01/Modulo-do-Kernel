#include <stdio.h>
#include "zigcalc_ioctl.h"

int main(void)
{
    printf("Tamanho da estrutura: %zu bytes\n",
           sizeof(struct zigcalc_request));

    printf("Soma: 0x%lx\n", (unsigned long)ZIGCALC_SOMA);
    printf("Subtracao: 0x%lx\n", (unsigned long)ZIGCALC_SUB);
    printf("Multiplicacao: 0x%lx\n", (unsigned long)ZIGCALC_MULT);
    printf("Divisao: 0x%lx\n", (unsigned long)ZIGCALC_DIV);

    if (sizeof(struct zigcalc_request) != 12)
        return 1;

    if (ZIGCALC_SOMA == ZIGCALC_SUB ||
        ZIGCALC_SOMA == ZIGCALC_MULT ||
        ZIGCALC_SOMA == ZIGCALC_DIV ||
        ZIGCALC_SUB == ZIGCALC_MULT ||
        ZIGCALC_SUB == ZIGCALC_DIV ||
        ZIGCALC_MULT == ZIGCALC_DIV)
        return 1;

    puts("ABI: OK");
    return 0;
}
