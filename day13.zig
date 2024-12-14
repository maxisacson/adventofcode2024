const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\Button A: X+94, Y+34
    \\Button B: X+22, Y+67
    \\Prize: X=8400, Y=5400
    \\
    \\Button A: X+26, Y+66
    \\Button B: X+67, Y+21
    \\Prize: X=12748, Y=12176
    \\
    \\Button A: X+17, Y+86
    \\Button B: X+84, Y+37
    \\Prize: X=7870, Y=6450
    \\
    \\Button A: X+69, Y+23
    \\Button B: X+27, Y+71
    \\Prize: X=18641, Y=10279
;

fn gcd(a: i64, b: i64) i64 {
    if (a < b) {
        return gcd(b, a);
    }
    if (b == 0) {
        return a;
    }

    return gcd(b, @mod(a, b));
}

const SolveError = error{
    NoSolution,
};

fn egcd(a: i64, b: i64, c: i64) ![3]i64 {
    var prev_r: i64 = a;
    var prev_s: i64 = 1;
    var prev_t: i64 = 0;

    var r: i64 = b;
    var s: i64 = 0;
    var t: i64 = 1;

    while (r != 0) {
        const q = @divTrunc(prev_r, r);
        const tmp_r = r;
        // std.debug.print("{d} {d} {d}\n", .{ prev_r, q, r });
        r = prev_r - q * r;
        prev_r = tmp_r;

        const tmp_s = s;
        s = prev_s - q * s;
        prev_s = tmp_s;

        const tmp_t = t;
        t = prev_t - q * t;
        prev_t = tmp_t;
    }

    const d = prev_r;
    var x = prev_s * @divTrunc(c, d);
    var y = prev_t * @divTrunc(c, d);

    if (@mod(c, d) != 0) {
        return SolveError.NoSolution;
    }

    const u = @divTrunc(a, d);
    const v = @divTrunc(b, d);

    if (x > 0) {
        const k = @divTrunc(x * d, b);
        x -= @divTrunc(k * b, d);
        y += @divTrunc(k * a, d);
    }

    if (x < 0) {
        const k = @divTrunc(-x * d, b);
        x += @divTrunc(k * b, d);
        y -= @divTrunc(k * a, d);
    }

    while (x < 0) {
        // std.debug.print("{d} {d}\n", .{ x, y });
        x += v;
        y -= u;
    }

    while (x - v > 0) {
        std.debug.print("{d} {d}\n", .{ x, y });
        x -= v;
        y += u;
    }
    std.debug.print("{d} {d}\n", .{ x, y });

    return .{ x, y, d };
}

fn solve(a1: i64, b1: i64, c1: i64, a2: i64, b2: i64, c2: i64) ![2]i64 {
    const X1 = try egcd(a1, b1, c1);

    var x1 = X1[0];
    var y1 = X1[1];
    const d1 = X1[2];

    if (d1 > 1) {
        return solve(@divTrunc(a1, d1), @divTrunc(b1, d1), @divTrunc(c1, d1), a2, b2, c2);
    }

    const d2 = gcd(a2, b2);
    if (@mod(c2, d2) != 0) {
        return SolveError.NoSolution;
    }

    if (d2 > 1) {
        return solve(a1, b1, c1, @divTrunc(a2, d2), @divTrunc(b2, d2), @divTrunc(c2, d2));
    }

    if (x1 < 0 or y1 < 0 or d1 < 0) {
        return SolveError.NoSolution;
    }

    const u = @divTrunc(a1, d1);
    const v = @divTrunc(b1, d1);

    if (u < 0 or v < 0) {
        return SolveError.NoSolution;
    }

    const C = c2 - x1 * a2 - y1 * b2;
    const U = v * a2 - u * b2;
    const k = @divTrunc(C, U);

    std.debug.print("{d} {d}\n", .{ x1, y1 });
    if (y1 < 0) {
        x1 -= k * v;
        y1 += k * u;
    } else if (y1 > 0) {
        x1 += k * v;
        y1 -= k * u;
    }
    std.debug.print("{d} {d}\n", .{ x1, y1 });

    while (y1 < 0) {
        // std.debug.print("{d} {d}\n", .{ x1, y1 });
        x1 -= v;
        y1 += u;
    }

    while (y1 >= 0) {
        // std.debug.print("{d} {d}\n", .{ x1, y1 });
        if (x1 * a2 + y1 * b2 == c2) {
            return .{ x1, y1 };
        }
        x1 += v;
        y1 -= u;
    }

    return SolveError.NoSolution;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var a1: i64 = undefined;
    var b1: i64 = undefined;
    var c1: i64 = undefined;
    var a2: i64 = undefined;
    var b2: i64 = undefined;
    var c2: i64 = undefined;

    var total: u64 = 0;
    for (lines, 0..) |line, i| {
        if (line.len > 0) {
            if (std.mem.eql(u8, line[0..8], "Button A")) {
                var split = std.mem.split(u8, line[10..], ", ");
                a1 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                a2 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
            } else if (std.mem.eql(u8, line[0..8], "Button B")) {
                var split = std.mem.split(u8, line[10..], ", ");
                b1 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                b2 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
            } else if (std.mem.eql(u8, line[0..5], "Prize")) {
                var split = std.mem.split(u8, line[7..], ", ");
                c1 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                c2 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
            }
        }
        if (line.len == 0 or i == lines.len - 1) {
            const solution = solve(a1, b1, c1, a2, b2, c2) catch |err| switch (err) {
                SolveError.NoSolution => {
                    continue;
                },
                else => unreachable,
            };
            const cost = 3 * solution[0] + solution[1];
            total += @intCast(cost);
        }
    }

    return total;
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var a1: i64 = undefined;
    var b1: i64 = undefined;
    var c1: i64 = undefined;
    var a2: i64 = undefined;
    var b2: i64 = undefined;
    var c2: i64 = undefined;

    const offset = 10000000000000;

    var total: u64 = 0;
    for (lines, 0..) |line, i| {
        if (line.len > 0) {
            if (std.mem.eql(u8, line[0..8], "Button A")) {
                var split = std.mem.split(u8, line[10..], ", ");
                a1 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                a2 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                printLn(line);
            } else if (std.mem.eql(u8, line[0..8], "Button B")) {
                var split = std.mem.split(u8, line[10..], ", ");
                b1 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                b2 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                printLn(line);
            } else if (std.mem.eql(u8, line[0..5], "Prize")) {
                var split = std.mem.split(u8, line[7..], ", ");
                c1 = try std.fmt.parseInt(i64, split.next().?[2..], 10) + offset;
                c2 = try std.fmt.parseInt(i64, split.next().?[2..], 10) + offset;
                printLn(line);
            }
        }
        if (line.len == 0 or i == lines.len - 1) {
            const solution = solve(a1, b1, c1, a2, b2, c2) catch |err| switch (err) {
                SolveError.NoSolution => {
                    std.debug.print("Cost: N/A\n\n", .{});
                    continue;
                },
                else => unreachable,
            };
            const cost = 3 * solution[0] + solution[1];
            std.debug.print("Cost: {d}\n\n", .{cost});
            total += @intCast(cost);
        }
    }

    return total;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day13.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "day13" {
    try testing.expectEqual(480, try run(test_input, testing.allocator));
    // try testing.expectEqual(0, try run2(test_input, testing.allocator));
}

test "tmp" {
    const input = try readFile("day13.txt", testing.allocator);
    defer testing.allocator.free(input);

    try testing.expectEqual(29711, try run(input, testing.allocator));
    // print("{d}\n", .{try run2(input, alloc)});
}
