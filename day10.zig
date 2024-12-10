const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\89010123
    \\78121874
    \\87430965
    \\96549874
    \\45678903
    \\32019012
    \\01329801
    \\10456732
;

fn score(map: *const utils.GridMap, index: usize, visited: []bool) !u64 {
    if (map.data[index] == '9') {
        if (visited[index]) {
            return 0;
        }
        visited[index] = true;
        return 1;
    }

    const row = try map.toRow(index);
    const col = try map.toCol(index);

    const neighbours = [_][2]i32{
        .{ 0, 1 },
        .{ 1, 0 },
        .{ 0, -1 },
        .{ -1, 0 },
    };

    var sum: u64 = 0;
    for (neighbours) |p| {
        const i, const j = p;
        if (!map.isValid(row + i, col + j)) {
            continue;
        }

        const next = try map.toIndex(row + i, col + j);
        if (map.data[index] + 1 == map.data[next]) {
            sum += try score(map, next, visited);
        }
    }
    return sum;
}

fn rate(map: *const utils.GridMap, index: usize) !u64 {
    if (map.data[index] == '9') {
        return 1;
    }

    const row = try map.toRow(index);
    const col = try map.toCol(index);

    const neighbours = [_][2]i32{
        .{ 0, 1 },
        .{ 1, 0 },
        .{ 0, -1 },
        .{ -1, 0 },
    };

    var sum: u64 = 0;
    for (neighbours) |p| {
        const i, const j = p;
        if (!map.isValid(row + i, col + j)) {
            continue;
        }

        const next = try map.toIndex(row + i, col + j);
        if (map.data[index] + 1 == map.data[next]) {
            sum += try rate(map, next);
        }
    }
    return sum;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var map = try utils.createGridMap(lines, alloc);
    defer alloc.free(map.data);

    const visited = try alloc.alloc(bool, map.data.len);
    defer alloc.free(visited);
    @memset(visited, false);

    var sum: u64 = 0;
    for (map.data, 0..) |p, i| {
        if (p == '0') {
            @memset(visited, false);
            sum += try score(&map, i, visited);
        }
    }
    return sum;
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var map = try utils.createGridMap(lines, alloc);
    defer alloc.free(map.data);

    var sum: u64 = 0;
    for (map.data, 0..) |p, i| {
        if (p == '0') {
            sum += try rate(&map, i);
        }
    }
    return sum;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day10.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "day10" {
    try testing.expectEqual(36, try run(test_input, testing.allocator));
    try testing.expectEqual(81, try run2(test_input, testing.allocator));
}
