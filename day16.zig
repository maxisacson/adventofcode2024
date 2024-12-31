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

const test_input2 =
    \\#################
    \\#...#...#...#..E#
    \\#.#.#.#.#.#.#.#.#
    \\#.#.#.#...#...#.#
    \\#.#.#.#.###.#.#.#
    \\#...#.#.#.....#.#
    \\#.#.#.#.#.#####.#
    \\#.#...#.#.#.....#
    \\#.#.#####.#.###.#
    \\#.#.#.......#...#
    \\#.#.###.#####.###
    \\#.#.#...#.....#.#
    \\#.#.#.#####.###.#
    \\#.#.#.........#.#
    \\#.#.#.#########.#
    \\#S#.............#
    \\#################
;

const test_input3 =
    \\#######
    \\#...#E#
    \\#...#.#
    \\#S....#
    \\#######
;

const test_input4 =
    \\#######
    \\#...#E#
    \\#.#.#.#
    \\#S#...#
    \\#######
;

const test_input5 =
    \\#############
    \\#...........#
    \\#.#########.#
    \\#.#########.#
    \\#.#.......#.#
    \\#...#...#...#
    \\#S#...#...#E#
    \\#############
;
// 16 + 11000
// 18 + 3000

const start_dir = '>';

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

    var dir = try alloc.alloc(u8, map.data.len);
    defer alloc.free(dir);
    @memset(dir, 0);
    dir[start] = start_dir;

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

        if (curr == end) {
            var i = curr;
            var path_map = try map.copy(alloc);
            defer alloc.free(path_map.data);

            var curr_cost: u64 = 0;
            var curr_dir = dir[i];

            if (prev[i] != -1 or map.data[i] == 'S') {
                while (prev[i] != -1) {
                    if (path_map.data[i] == '.') {
                        // path_map.data[i] = '*';
                        path_map.data[i] = dir[i];
                    } else {
                        path_map.data[i] = dir[i];
                    }

                    i = @intCast(prev[i]);

                    if (dir[i] != curr_dir) {
                        curr_cost += 1000;
                    }
                    curr_cost += 1;
                    curr_dir = dir[i];
                }
            }
            path_map.data[start] = dir[start];

            if (dir[start] != curr_dir) {
                curr_cost += 1000;
            }

            path_map.print();

            print("{d} {d}\n", .{ cost[curr], curr_cost });
            return cost[curr];
            // return curr_cost;
        }

        // const pos = try map.toPos(curr);
        // const nbrs = [_][2]i64{
        //     .{ pos[0], pos[1] - 1 },
        //     .{ pos[0] + 1, pos[1] },
        //     .{ pos[0], pos[1] + 1 },
        //     .{ pos[0] - 1, pos[1] },
        // };
        const nbrs = try getNeighbours(map, dir[curr], curr);

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
            const next_cost = try getCost(map, curr, next, prev, cost);
            if (next_cost < cost[next]) {
                cost[next] = next_cost;
                prev[next] = @intCast(curr);
                dir[next] = getDir(diff2(map, next, curr));
            }
        }
    }

    unreachable;
}

fn getNeighbours(map: utils.GridMap, dir: u8, curr: usize) ![3][2]i64 {
    const row = try map.toRow(curr);
    const col = try map.toCol(curr);
    return switch (dir) {
        '<' => [_][2]i64{
            .{ row - 1, col },
            .{ row, col - 1 },
            .{ row + 1, col },
        },
        'v' => [_][2]i64{
            .{ row, col + 1 },
            .{ row, col - 1 },
            .{ row + 1, col },
        },
        '^' => [_][2]i64{
            .{ row, col + 1 },
            .{ row, col - 1 },
            .{ row - 1, col },
        },
        '>' => [_][2]i64{
            .{ row - 1, col },
            .{ row, col + 1 },
            .{ row + 1, col },
        },
        else => {
            print("dir:{d}\n", .{dir});
            unreachable;
        },
    };
}

fn getNeighbours2(map: utils.GridMap, _: u8, curr: usize) ![3][2]i64 {
    const row = try map.toRow(curr);
    const col = try map.toCol(curr);

    return [_][2]i64{
        .{ row - 1, col },
        .{ row, col - 1 },
        .{ row + 1, col },
        .{ row, col + 1 },

        .{ row - 1, col + 1 },
        .{ row - 1, col - 1 },
        .{ row + 1, col + 1 },
        .{ row + 1, col - 1 },

        .{ row - 2, col },
        .{ row, col - 2 },
        .{ row + 2, col },
        .{ row, col + 2 },
    };
}

fn getCost(map: utils.GridMap, curr: usize, next: usize, prev: []i64, cost: []u64) !u64 {
    const curr_pos = try map.toPos(curr);
    var curr_dir: u8 = start_dir;
    if (prev[curr] != -1) {
        const prev_pos = try map.toPos(@intCast(prev[curr]));
        curr_dir = getDir(diff(curr_pos, prev_pos));
    }

    const next_pos = try map.toPos(next);
    const next_dir = getDir(diff(next_pos, curr_pos));

    if (curr_dir != next_dir) {
        return cost[curr] + 1001;
    }
    return cost[curr] + 1;
}

fn getCost2(map: utils.GridMap, curr: usize, next: usize, prev: []i64, cost: []u64) !u64 {
    const curr_pos = try map.toPos(curr);
    var curr_dir: u8 = start_dir;
    if (prev[curr] != -1) {
        const prev_pos = try map.toPos(@intCast(prev[curr]));
        curr_dir = getDir(diff(curr_pos, prev_pos));
    }

    const next_pos = try map.toPos(next);
    var next_dir = undefined;
    const d = diff(next_pos, curr_pos);
    if (d[0] == 0) {
        if (d[1] < 0) {
            next_dir = '<';
        } else if (d[1] > 0) {
            next_dir = '>';
        } else unreachable;
    } else if (d[1] == 0) {
        if (d[0] < 0) {
            next_dir = '^';
        } else if (d[0] > 0) {
            next_dir = 'v';
        } else unreachable;
    } else if (d[0] == 1 and d[1] == 1) {} else if (d[0] == -1 and d[1] == 1) {} else if (d[0] == 1 and d[1] == -1) {} else if (d[0] == -1 and d[1] == -1) {}

    if (curr_dir != next_dir) {
        return cost[curr] + 1001;
    }
    return cost[curr] + 1;
}

fn diff(a: [2]i64, b: [2]i64) [2]i64 {
    return .{ a[0] - b[0], a[1] - b[1] };
}

fn diff2(map: utils.GridMap, a: usize, b: usize) [2]i64 {
    const pos_a = map.toPos(a) catch .{ 0, 0 };
    const pos_b = map.toPos(b) catch .{ 0, 0 };
    return diff(pos_a, pos_b);
}

fn getDir(d: [2]i64) u8 {
    if (d[0] == 0) {
        return switch (d[1]) {
            1 => '>',
            -1 => '<',
            else => unreachable,
        };
    }

    if (d[1] == 0) {
        return switch (d[0]) {
            1 => 'v',
            -1 => '^',
            else => unreachable,
        };
    }

    unreachable;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    const map = try utils.createGridMap(lines, alloc);
    defer alloc.free(map.data);

    const start = for (map.data, 0..) |v, i| {
        if (v == 'S') {
            break i;
        }
    } else {
        unreachable;
    };

    const end = for (map.data, 0..) |v, i| {
        if (v == 'E') {
            break i;
        }
    } else {
        unreachable;
    };

    const minCost = try findPathDijkstra(map, start, end, alloc);
    return minCost;
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
    // print("{d}\n", .{try run2(input, alloc)});
}

test "day16" {
    try testing.expectEqual(7036, try run(test_input, testing.allocator));
    try testing.expectEqual(11048, try run(test_input2, testing.allocator));
    try testing.expectEqual(1006, try run(test_input3, testing.allocator));
    try testing.expectEqual(5010, try run(test_input4, testing.allocator));
    try testing.expectEqual(3020, try run(test_input5, testing.allocator));
    // try testing.expectEqual(0, try run2(test_input, testing.allocator));
}
