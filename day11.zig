const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input = "125 17";

fn blink(numbers: []const u64, alloc: Allocator) ![]u64 {
    var list = std.ArrayList(u64).init(alloc);
    defer list.deinit();

    for (numbers) |n| {
        if (n == 0) {
            try list.append(1);
            continue;
        }

        const s = try std.fmt.allocPrint(alloc, "{d}", .{n});
        defer alloc.free(s);
        if (s.len % 2 == 0) {
            try list.append(try std.fmt.parseInt(u64, s[0 .. s.len / 2], 10));
            try list.append(try std.fmt.parseInt(u64, s[s.len / 2 ..], 10));
            continue;
        }

        try list.append(2024 * n);
    }

    return list.toOwnedSlice();
}

fn count(number: u64, depth: u64, cache: *std.AutoHashMap([2]u64, u64), alloc: Allocator) !u64 {
    if (depth <= 0) {
        return 1;
    }

    const k = .{ number, depth };

    if (cache.*.contains(k)) {
        return cache.*.get(k).?;
    }

    if (number == 0) {
        const v = try count(1, depth - 1, cache, alloc);
        try cache.put(k, v);
        return v;
    }

    const s = try std.fmt.allocPrint(alloc, "{d}", .{number});
    defer alloc.free(s);

    if (s.len % 2 == 0) {
        const n1 = try std.fmt.parseInt(u64, s[0 .. s.len / 2], 10);
        const n2 = try std.fmt.parseInt(u64, s[s.len / 2 ..], 10);

        const v1 = try count(n1, depth - 1, cache, alloc);
        const v2 = try count(n2, depth - 1, cache, alloc);

        try cache.put(k, v1 + v2);
        return v1 + v2;
    }

    const v = try count(2024 * number, depth - 1, cache, alloc);
    try cache.put(k, v);
    return v;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var numbers = try utils.toSlice(u64, lines[0], " ", alloc);
    defer alloc.free(numbers);

    for (0..25) |_| {
        const temp = try blink(numbers, alloc);
        alloc.free(numbers);
        numbers = temp;
    }

    return @intCast(numbers.len);
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    const numbers = try utils.toSlice(u64, lines[0], " ", alloc);
    defer alloc.free(numbers);

    var cache = std.AutoHashMap([2]u64, u64).init(alloc);
    defer cache.deinit();

    var sum: u64 = 0;
    for (numbers) |n| {
        sum += try count(n, 75, &cache, alloc);
    }

    return sum;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day11.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "day11" {
    try testing.expectEqual(55312, try run(test_input, testing.allocator));
    try testing.expectEqual(65601038650482, try run2(test_input, testing.allocator));
}
