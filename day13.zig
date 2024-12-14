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

fn solve(a1: i64, b1: i64, c1: i64, a2: i64, b2: i64, c2: i64) ![2]i64 {
    const d1 = gcd(a1, b1);
    if (@mod(c1, d1) != 0) {
        return SolveError.NoSolution;
    }

    const d2 = gcd(a2, b2);
    if (@mod(c2, d2) != 0) {
        return SolveError.NoSolution;
    }

    const C = a2 * c1 - a1 * c2;
    const B = a2 * b1 - a1 * b2;

    if (@mod(C, B) != 0) {
        return SolveError.NoSolution;
    }
    const y = @divExact(C, B);

    if (@mod(c1 - b1 * y, a1) != 0) {
        return SolveError.NoSolution;
    }
    const x = @divExact(c1 - b1 * y, a1);

    if (x < 0) {
        unreachable;
    }

    if (y < 0) {
        unreachable;
    }

    return .{ x, y };
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
            } else if (std.mem.eql(u8, line[0..8], "Button B")) {
                var split = std.mem.split(u8, line[10..], ", ");
                b1 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
                b2 = try std.fmt.parseInt(i64, split.next().?[2..], 10);
            } else if (std.mem.eql(u8, line[0..5], "Prize")) {
                var split = std.mem.split(u8, line[7..], ", ");
                c1 = try std.fmt.parseInt(i64, split.next().?[2..], 10) + offset;
                c2 = try std.fmt.parseInt(i64, split.next().?[2..], 10) + offset;
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
    try testing.expectEqual(875318608908, try run2(test_input, testing.allocator));
}
