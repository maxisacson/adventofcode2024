const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\5,4
    \\4,2
    \\4,5
    \\3,0
    \\2,1
    \\6,3
    \\2,4
    \\1,5
    \\0,6
    \\3,3
    \\2,6
    \\5,1
    \\1,2
    \\5,5
    \\2,5
    \\6,5
    \\1,4
    \\0,4
    \\6,4
    \\1,1
    \\6,1
    \\1,0
    \\0,5
    \\1,6
    \\2,0
;

const PathError = error{NoPath};

fn findPathDijkstra(map: utils.GridMap, start: usize, end: usize, alloc: Allocator) !u64 {
    var cost = try alloc.alloc(u64, map.data.len);
    defer alloc.free(cost);
    @memset(cost, std.math.maxInt(u64));
    cost[start] = 0;

    var prev = try alloc.alloc(i64, map.data.len);
    defer alloc.free(prev);
    @memset(prev, -1);

    var visited = try alloc.alloc(bool, map.data.len);
    defer alloc.free(visited);
    @memset(visited, false);

    while (true) {
        const curr = blk: {
            var k_min: ?usize = null;
            for (0..map.data.len) |k| {
                if (visited[k]) {
                    continue;
                }
                if (k_min == null or cost[k] < cost[k_min.?]) {
                    k_min = k;
                }
            }
            break :blk k_min.?;
        };
        visited[curr] = true;

        if (cost[curr] == std.math.maxInt(u64)) {
            return PathError.NoPath;
        }

        if (curr == end) {
            var i = end;
            if (prev[i] != -1 or i == start) {
                while (true) {
                    map.data[i] = 'O';
                    if (prev[i] == -1) {
                        break;
                    }
                    i = @intCast(prev[i]);
                }
            }
            return cost[curr];
        }

        const pos = try map.toPos(curr);
        const nbrs = [_][2]i64{
            .{ pos[0], pos[1] - 1 },
            .{ pos[0] + 1, pos[1] },
            .{ pos[0] - 1, pos[1] },
            .{ pos[0], pos[1] + 1 },
        };

        for (nbrs) |n| {
            if (!map.isValid(n[0], n[1])) {
                continue;
            }
            const next = try map.toIndex(n[0], n[1]);
            if (map.data[next] == '#') {
                continue;
            }
            if (visited[next]) {
                continue;
            }
            const next_cost = cost[curr] + 1;
            if (next_cost < cost[next]) {
                cost[next] = next_cost;
                prev[next] = @intCast(curr);
            }
        }
    }

    unreachable;
}

fn run(input: []const u8, size: usize, nbytes: usize, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var map = try utils.createEmptyGridMap(size, size, alloc);
    defer alloc.free(map.data);

    map.reset('.');

    for (0..nbytes) |i| {
        const pos = try utils.toSlice(i64, lines[i], ",", alloc);
        defer alloc.free(pos);
        try map.set(pos[1], pos[0], '#');
    }

    const start = try map.toIndex(0, 0);
    const end = try map.toIndex(@intCast(size - 1), @intCast(size - 1));
    const steps = try findPathDijkstra(map, start, end, alloc);

    return steps;
}

fn run2(input: []const u8, size: usize, nbytes: usize, alloc: Allocator) ![]const u8 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var orig = try utils.createEmptyGridMap(size, size, alloc);
    defer alloc.free(orig.data);

    orig.reset('.');

    for (0..nbytes) |i| {
        const pos = try utils.toSlice(i64, lines[i], ",", alloc);
        defer alloc.free(pos);
        try orig.set(pos[1], pos[0], '#');
    }

    var map = try orig.copy(alloc);
    defer alloc.free(map.data);

    const start = try map.toIndex(0, 0);
    const end = try map.toIndex(@intCast(size - 1), @intCast(size - 1));

    _ = try findPathDijkstra(map, start, end, alloc);

    const byte = for (nbytes..lines.len) |i| {
        const pos = try utils.toSlice(i64, lines[i], ",", alloc);
        defer alloc.free(pos);

        try orig.set(pos[1], pos[0], '#');

        if (try map.get(pos[1], pos[0]) != 'O') {
            continue;
        }

        const copy = try orig.copy(alloc);
        defer alloc.free(copy.data);
        _ = findPathDijkstra(copy, start, end, alloc) catch |err| {
            switch (err) {
                PathError.NoPath => {
                    break i;
                },
                else => return err,
            }
        };

        std.mem.copyForwards(u8, map.data, copy.data);
    } else {
        unreachable;
    };

    return lines[byte];
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day18.txt", alloc);

    print("{d}\n", .{try run(input, 71, 1024, alloc)});
    print("{s}\n", .{try run2(input, 71, 1024, alloc)});
}

test "day18" {
    try testing.expectEqual(22, try run(test_input, 7, 12, testing.allocator));

    const str = try run2(test_input, 7, 12, testing.allocator);
    try testing.expect(std.mem.eql(u8, "6,1", str));
}
