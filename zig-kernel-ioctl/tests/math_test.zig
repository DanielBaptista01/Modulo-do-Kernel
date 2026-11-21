const std = @import("std");
const calc = @import("calc");

fn check(
    op: c_int,
    a: c_int,
    b: c_int,
    expected_status: c_int,
    expected_result: c_int,
) !void {
    var result: c_int = 12345;
    const status = calc.zigcalc_compute(op, a, b, &result);

    try std.testing.expectEqual(expected_status, status);

    if (status == 0) {
        try std.testing.expectEqual(expected_result, result);
    } else {
        try std.testing.expectEqual(@as(c_int, 12345), result);
    }
}

test "operacoes validas" {
    try check(1, 10, 20, 0, 30);
    try check(2, 50, 15, 0, 35);
    try check(3, 7, 8, 0, 56);
    try check(4, 100, 4, 0, 25);
    try check(4, -7, 2, 0, -3);
}

test "divisao por zero" {
    try check(4, 10, 0, 1, 0);
}

test "transbordamentos" {
    try check(1, 2147483647, 1, 2, 0);
    try check(2, -2147483648, 1, 2, 0);
    try check(3, 2147483647, 2, 2, 0);
    try check(4, -2147483648, -1, 2, 0);
}

test "operacao desconhecida" {
    try check(99, 10, 20, 3, 0);
}

test "limites validos" {
    try check(1, 2147483647, 0, 0, 2147483647);
    try check(2, -2147483648, 0, 0, -2147483648);
}
