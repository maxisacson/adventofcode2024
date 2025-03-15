const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\###############
    \\#...#...#.....#
    \\#.#.#.#.#.###.#
    \\#S#...#.#.#...#
    \\#######.#.#.###
    \\#######.#.#...#
    \\#######.#.###.#
    \\###..E#...#...#
    \\###.#######.###
    \\#...###...#...#
    \\#.#####.#.###.#
    \\#.#...#.#.#...#
    \\#.#.#.#.#.#.###
    \\#...#...#...###
    \\###############
;

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var map = try utils.createGridMap(lines, alloc);

    var start: usize = undefined;
    var end: usize = undefined;
    for (map.data, 0..) |v, i| {
        if (v == 'S') {
            start = i;
        }
        if (v == 'E') {
            end = i;
        }
    }

    return @intCast(lines.len);
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
    const input = try readFile("day20.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "day20" {
    try testing.expectEqual(0, try run(test_input, testing.allocator));
    try testing.expectEqual(0, try run2(test_input, testing.allocator));
}
