const std = @import("std");

extern "c" fn open(path: [*:0]const u8, flags: c_int) c_int;
extern "c" fn close(fd: c_int) c_int;
extern "c" fn ioctl(fd: c_int, request: c_ulong, ...) c_int;
extern "c" fn printf(fmt: [*:0]const u8, ...) c_int;
extern "c" fn perror(message: [*:0]const u8) void;
extern "c" fn __errno_location() *c_int;

const Request = extern struct {
    a: i32,
    b: i32,
    resultado: i32,
};

fn comandoIoctl(op: u8) c_ulong {
    return (@as(c_ulong, 3) << 30) |
        (@as(c_ulong, @sizeOf(Request)) << 16) |
        (@as(c_ulong, 'Z') << 8) |
        @as(c_ulong, op);
}

fn operacao(nome: []const u8) ?u8 {
    if (std.mem.eql(u8, nome, "soma")) return 1;
    if (std.mem.eql(u8, nome, "sub")) return 2;
    if (std.mem.eql(u8, nome, "mult")) return 3;
    if (std.mem.eql(u8, nome, "div")) return 4;
    if (std.mem.eql(u8, nome, "desconhecido")) return 99;
    return null;
}

pub export fn main(
    argc: c_int,
    argv: [*]const [*:0]const u8,
) c_int {
    if (argc != 4) {
        _ = printf(
            "Uso: ./zigcalc <soma|sub|mult|div> <a> <b>\n",
        );
        return 1;
    }

    const nome = std.mem.span(argv[1]);
    const op = operacao(nome) orelse {
        _ = printf("Erro: operacao invalida\n");
        return 1;
    };

    const a = std.fmt.parseInt(
        i32, std.mem.span(argv[2]), 10,
    ) catch {
        _ = printf("Erro: primeiro operando invalido\n");
        return 1;
    };

    const b = std.fmt.parseInt(
        i32, std.mem.span(argv[3]), 10,
    ) catch {
        _ = printf("Erro: segundo operando invalido\n");
        return 1;
    };

    var req = Request{
        .a = a,
        .b = b,
        .resultado = 0,
    };

    const fd = open("/dev/zigcalc", 2);
    if (fd < 0) {
        perror("Erro ao abrir /dev/zigcalc");
        return 1;
    }
    defer _ = close(fd);

    const ret = ioctl(fd, comandoIoctl(op), &req);

    if (ret < 0) {
        const err = __errno_location().*;

        if (err == 33) {
            _ = printf("Erro: divisao por zero\n");
        } else if (err == 34) {
            _ = printf("Erro: overflow aritmetico\n");
        } else if (err == 25) {
            _ = printf("Erro: comando desconhecido\n");
        } else if (err == 14) {
            _ = printf("Erro: ponteiro invalido\n");
        } else {
            perror("Erro no ioctl");
        }

        return 1;
    }

    _ = printf("Resultado: %d\n", req.resultado);
    return 0;
}
