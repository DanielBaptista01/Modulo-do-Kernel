#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include "zigcalc_ioctl.h"

int main(void)
{
    int fd = open("/dev/zigcalc", O_RDWR);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    errno = 0;
    int ret = ioctl(fd, ZIGCALC_SOMA, (void *)1);
    int erro = errno;

    close(fd);

    if (ret == -1 && erro == EFAULT) {
        puts("EFAULT: OK");
        return 0;
    }

    fprintf(stderr, "FALHA: retorno=%d errno=%d\n",
            ret, erro);
    return 1;
}
