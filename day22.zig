const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\1
    \\10
    \\100
    \\2024
;

fn next(n: u64) u64 {
    var k = n;

    k ^= k << 6;
    k %= 16777216;

    k ^= k >> 5;
    k %= 16777216;

    k ^= k << 11;
    k %= 16777216;

    return k;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var sum: u64 = 0;
    for (lines) |line| {
        var n = try std.fmt.parseInt(u64, line, 10);
        for (0..2000) |_| {
            n = next(n);
        }
        sum += n;
    }

    return sum;
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    return @intCast(lines.len);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day22.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    // print("{d}\n", .{try run2(input, alloc)});
}

test "day22" {
    try testing.expectEqual(37327623, try run(test_input, testing.allocator));
    // try testing.expectEqual(23, try run2(test_input2, testing.allocator));
}
