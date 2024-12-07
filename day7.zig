const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const readFile = utils.readFile;

const test_input =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

fn check(target: u64, operands: []u32, result: u64, op: u8, possible_ops: []const u8, depth: u64) !u64 {
    const alloc = arena.allocator();
    if (depth >= operands.len) {
        return if (result == target) result else 0;
    }

    if (result > target) {
        return 0;
    }

    const x = operands[depth];
    const next_result = switch (op) {
        '+' => result + x,
        '*' => result * x,
        '|' => blk: {
            const result_str = try std.fmt.allocPrint(alloc, "{d}{d}", .{ result, x });
            defer alloc.free(result_str);
            const tmp_result = try std.fmt.parseInt(u64, result_str, 10);
            break :blk tmp_result;
        },
        else => unreachable,
    };

    for (possible_ops) |pop| {
        const res = try check(target, operands, next_result, pop, possible_ops, depth + 1);
        if (res != 0) {
            return res;
        }
    }
    return 0;
}

fn checkCalibration(target: u64, operands: []u32, possible_ops: []const u8) !u64 {
    for (possible_ops) |op| {
        const res = try check(target, operands, operands[0], op, possible_ops, 1);
        if (res != 0) {
            return res;
        }
    }
    return 0;
}

fn run(input: []const u8) !u64 {
    const alloc = arena.allocator();

    var sum: u64 = 0;

    var row = std.mem.splitScalar(u8, input, '\n');
    while (row.next()) |line| {
        if (line.len == 0 and row.peek() == null) {
            break;
        }
        var iter = std.mem.tokenizeSequence(u8, line, ": ");
        const target = iter.next().?;

        const operands = try utils.toSlice(u32, iter.next().?, " ", alloc);
        defer alloc.free(operands);

        sum += try checkCalibration(try std.fmt.parseInt(u64, target, 10), operands, "+*");
    }

    return sum;
}

fn run2(input: []const u8) !u64 {
    const alloc = arena.allocator();

    var sum: u64 = 0;

    var row = std.mem.splitScalar(u8, input, '\n');
    while (row.next()) |line| {
        if (line.len == 0 and row.peek() == null) {
            break;
        }
        var iter = std.mem.tokenizeSequence(u8, line, ": ");
        const target = iter.next().?;

        const operands = try utils.toSlice(u32, iter.next().?, " ", alloc);
        defer alloc.free(operands);

        sum += try checkCalibration(try std.fmt.parseInt(u64, target, 10), operands, "+*|");
    }

    return sum;
}

pub fn main() !void {
    defer arena.deinit();
    const input = try readFile("day7.txt");
    print("{d}\n", .{try run(input)});
    print("{d}\n", .{try run2(input)});
}

test "day7" {
    defer arena.deinit();

    try testing.expectEqual(3749, try run(test_input));
    try testing.expectEqual(11387, try run2(test_input));
}
