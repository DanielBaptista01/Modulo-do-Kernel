const STATUS_OK: c_int = 0;
const STATUS_DIVZERO: c_int = 1;
const STATUS_OVERFLOW: c_int = 2;
const STATUS_INVALID: c_int = 3;

pub export fn zigcalc_compute(
    operacao: c_int,
    a: c_int,
    b: c_int,
    resultado: *c_int,
) c_int {
    switch (operacao) {
        1 => {
            const r = @addWithOverflow(a, b);
            if (r[1] != 0) return STATUS_OVERFLOW;
            resultado.* = r[0];
        },
        2 => {
            const r = @subWithOverflow(a, b);
            if (r[1] != 0) return STATUS_OVERFLOW;
            resultado.* = r[0];
        },
        3 => {
            const r = @mulWithOverflow(a, b);
            if (r[1] != 0) return STATUS_OVERFLOW;
            resultado.* = r[0];
        },
        4 => {
            if (b == 0) return STATUS_DIVZERO;

            if (a == -2147483648 and b == -1)
                return STATUS_OVERFLOW;

            resultado.* = @divTrunc(a, b);
        },
        else => return STATUS_INVALID,
    }

    return STATUS_OK;
}
