const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\###############
    \\#.......#....E#
    \\#.#.###.#.###.#
    \\#.....#.#...#.#
    \\#.###.#####.#.#
    \\#.#.#.......#.#
    \\#.#.#####.###.#
    \\#...........#.#
    \\###.#.#####.#.#
    \\#...#.....#.#.#
    \\#.#.#.###.#.#.#
    \\#.....#...#.#.#
    \\#.###.#.#.#.#.#
    \\#S..#.....#...#
    \\###############
;

fn findPaths(map: utils.GridMap, pos: [2]i64, visited: []bool, alloc: Allocator) ![][2]i64 {
    visited[try map.toIndex(pos[0], pos[1])] = true;

    const nbrs = [_][2]i64{
        .{ pos[0] + 1, pos[1] },
        .{ pos[0] - 1, pos[1] },
        .{ pos[0], pos[1] + 1 },
        .{ pos[0], pos[1] - 1 },
    };

    var paths = std.ArrayList([][2]i64).init(alloc);
    defer paths.deinit();

    for (nbrs) |n| {
        if (!map.isValid(n[0], n[1])) {
            continue;
        }
        if (visited[try map.toIndex(n[0], n[1])]) {
            continue;
        }
        const visited_copy = try alloc.alloc(bool, map.data.len);
        std.mem.copyForwards(bool, visited_copy, visited);
        defer alloc.free(visited_copy);
        const tmp_paths = try findPaths(map, n, visited_copy, alloc);
        for (tmp_paths) |path| {
            var tmp_path = std.ArrayList([2]i64).init(alloc);
            defer tmp_path.deinit();
            try tmp_path.append(pos);
            for (path) |p| {
                try tmp_path.append(p);
            }
            paths.append(tmp_path.toOwnedSlice());
        }
    }
    return paths.toOwnedSlice();
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var map = try utils.createGridMap(lines, alloc);
    defer alloc.free(map.data);

    const start = for (map.data, 0..) |v, i| {
        if (v == 'S') {
            break .{ try map.toRow(i), try map.toCol(i) };
        }
    } else {
        unreachable;
    };

    const visited = try alloc.alloc(bool, map.data.len);
    defer alloc.free(visited);

    const paths = try findPaths(map, start, visited, alloc);

    return @intCast(paths.len);
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
    const input = try readFile("day16.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "day16" {
    try testing.expectEqual(0, try run(test_input, testing.allocator));
    try testing.expectEqual(0, try run2(test_input, testing.allocator));
}
