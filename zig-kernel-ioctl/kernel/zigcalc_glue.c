
#include <linux/module.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>
#include <linux/errno.h>

#include "zigcalc_ioctl.h"

/*
 * Funcao implementada em Zig pelo Integrante 2.
 * Retorna um status e escreve o resultado no ponteiro.
 */
extern int zigcalc_compute(int operacao, int a, int b,
                           int *resultado);

/* Manipulador das chamadas ioctl */
static long zigcalc_ioctl(struct file *file,
                          unsigned int cmd,
                          unsigned long arg)
{
    struct zigcalc_request req;
    void __user *user_ptr = (void __user *)arg;
    int operacao;
    int status;

    /* Identifica o comando solicitado */
    switch (cmd) {
    case ZIGCALC_SOMA:
        operacao = ZIGCALC_OP_SOMA;
        break;
    case ZIGCALC_SUB:
        operacao = ZIGCALC_OP_SUB;
        break;
    case ZIGCALC_MULT:
        operacao = ZIGCALC_OP_MULT;
        break;
    case ZIGCALC_DIV:
        operacao = ZIGCALC_OP_DIV;
        break;
    default:
        return -ENOTTY;
    }

    /* Copia os dados do usuario para o kernel */
    if (copy_from_user(&req, user_ptr, sizeof(req)))
        return -EFAULT;

    /* Executa o calculo por meio do codigo Zig */
    status = zigcalc_compute(operacao, req.a,
                             req.b, &req.resultado);

    /* Traduz os erros produzidos pelo Zig */
    switch (status) {
    case ZIGCALC_STATUS_OK:
        break;
    case ZIGCALC_STATUS_DIVZERO:
        return -EDOM;
    case ZIGCALC_STATUS_OVERFLOW:
        return -ERANGE;
    case ZIGCALC_STATUS_INVALID:
        return -ENOTTY;
    default:
        return -EINVAL;
    }

    /* Devolve o resultado ao programa cliente */
    if (copy_to_user(user_ptr, &req, sizeof(req)))
        return -EFAULT;

    return 0;
}

/* Operacoes disponibilizadas pelo dispositivo */
static const struct file_operations zigcalc_fops = {
    .owner = THIS_MODULE,
    .unlocked_ioctl = zigcalc_ioctl,
    .llseek = no_llseek,
};

/* Registro do dispositivo de caractere */
static struct miscdevice zigcalc_device = {
    .minor = MISC_DYNAMIC_MINOR,
    .name = "zigcalc",
    .fops = &zigcalc_fops,
    .mode = 0600,
};

/* Executado quando o modulo e carregado */
static int __init zigcalc_init(void)
{
    int ret;

    ret = misc_register(&zigcalc_device);

    if (ret) {
        pr_err("zigcalc: erro ao registrar dispositivo\n");
        return ret;
    }

    pr_info("zigcalc: modulo carregado\n");

    return 0;
}

/* Executado quando o modulo e removido */
static void __exit zigcalc_exit(void)
{
    misc_deregister(&zigcalc_device);

    pr_info("zigcalc: modulo descarregado\n");
}

module_init(zigcalc_init);
module_exit(zigcalc_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Calculadora Zig integrada ao kernel Linux");
MODULE_AUTHOR("Equipe zig-kernel-ioctl");
