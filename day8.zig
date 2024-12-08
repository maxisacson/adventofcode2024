const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
;

const Pos = struct {
    i: i64,
    j: i64,
};

const Map = struct {
    rows: i64 = 0,
    cols: i64 = 0,
    data: []u8,

    pub fn isValid(self: *Map, i: i64, j: i64) bool {
        return (0 <= i and i < self.rows and 0 <= j and j < self.cols);
    }

    pub fn get(self: *Map, i: i64, j: i64) u8 {
        const index: usize = @intCast(j + i * self.cols);
        return self.data[index];
    }

    pub fn set(self: *Map, i: i64, j: i64, value: u8) void {
        const index: usize = @intCast(j + i * self.cols);
        self.data[index] = value;
    }

    pub fn print(self: *const Map) void {
        const rows: usize = @intCast(self.rows);
        const cols: usize = @intCast(self.cols);
        for (0..rows) |row| {
            for (0..cols) |col| {
                std.debug.print("{c}", .{self.data[col + cols * row]});
            }
            std.debug.print("\n", .{});
        }
    }

    pub fn toIndex(self: *const Map, i: i64, j: i64) usize {
        return @intCast(j + i * self.cols);
    }
};

fn checkPositions(list: []const Pos, map: *Map) u64 {
    var count: u64 = 0;

    for (0..list.len - 1) |i| {
        for (i + 1..list.len) |j| {
            const p1 = list[i];
            const p2 = list[j];

            const dy: i64 = p2.i - p1.i;
            const dx: i64 = p2.j - p1.j;

            const forward = Pos{ .i = p2.i + dy, .j = p2.j + dx };
            const backward = Pos{ .i = p1.i - dy, .j = p1.j - dx };

            if (map.*.isValid(forward.i, forward.j)) {
                if (map.*.get(forward.i, forward.j) != '#') {
                    map.*.set(forward.i, forward.j, '#');
                    count += 1;
                }
            }

            if (map.*.isValid(backward.i, backward.j)) {
                if (map.*.get(backward.i, backward.j) != '#') {
                    map.*.set(backward.i, backward.j, '#');
                    count += 1;
                }
            }
        }
    }

    return count;
}

fn checkPositions2(list: []const Pos, map: *Map) u64 {
    var count: u64 = 0;

    for (0..list.len - 1) |i| {
        for (i + 1..list.len) |j| {
            const p1 = list[i];
            const p2 = list[j];

            const dy: i64 = p2.i - p1.i;
            const dx: i64 = p2.j - p1.j;

            var n: i64 = 0;
            while (true) : (n += 1) {
                const next = Pos{
                    .i = p1.i + n * dy,
                    .j = p1.j + n * dx,
                };
                if (map.*.isValid(next.i, next.j)) {
                    if (map.*.get(next.i, next.j) != '#') {
                        map.*.set(next.i, next.j, '#');
                        count += 1;
                    }
                } else {
                    break;
                }
            }

            n = 0;
            while (true) : (n += 1) {
                const next = Pos{
                    .i = p1.i - n * dy,
                    .j = p1.j - n * dx,
                };
                if (map.*.isValid(next.i, next.j)) {
                    if (map.*.get(next.i, next.j) != '#') {
                        map.*.set(next.i, next.j, '#');
                        count += 1;
                    }
                } else {
                    break;
                }
            }
        }
    }

    return count;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    var row = std.mem.tokenizeScalar(u8, input, '\n');

    var positions = std.AutoHashMap(u8, std.ArrayList(Pos)).init(alloc);
    defer {
        var it = positions.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        positions.deinit();
    }

    const cols = row.peek().?.len;

    var data = std.ArrayList(u8).init(alloc);
    defer data.deinit();

    var i: i64 = 0;
    while (row.next()) |line| : (i += 1) {
        try data.appendSlice(line);
        for (line, 0..) |c, j| {
            if (std.ascii.isAlphanumeric(c)) {
                const pos = Pos{ .i = i, .j = @intCast(j) };
                if (!positions.contains(c)) {
                    const list = std.ArrayList(Pos).init(alloc);
                    try positions.put(c, list);
                }
                try positions.getPtr(c).?.*.append(pos);
            }
        }
    }

    var map = Map{
        .rows = i,
        .cols = @intCast(cols),
        .data = try data.toOwnedSlice(),
    };
    defer alloc.free(map.data);

    var sum: u64 = 0;
    var it = positions.iterator();
    while (it.next()) |kv| {
        sum += checkPositions(kv.value_ptr.*.items, &map);
    }

    return sum;
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    var row = std.mem.tokenizeScalar(u8, input, '\n');

    var positions = std.AutoHashMap(u8, std.ArrayList(Pos)).init(alloc);
    defer {
        var it = positions.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        positions.deinit();
    }

    const cols = row.peek().?.len;

    var data = std.ArrayList(u8).init(alloc);
    defer data.deinit();

    var i: i64 = 0;
    while (row.next()) |line| : (i += 1) {
        try data.appendSlice(line);
        for (line, 0..) |c, j| {
            if (std.ascii.isAlphanumeric(c)) {
                const pos = Pos{ .i = i, .j = @intCast(j) };
                if (!positions.contains(c)) {
                    const list = std.ArrayList(Pos).init(alloc);
                    try positions.put(c, list);
                }
                try positions.getPtr(c).?.*.append(pos);
            }
        }
    }

    var map = Map{
        .rows = i,
        .cols = @intCast(cols),
        .data = try data.toOwnedSlice(),
    };
    defer alloc.free(map.data);

    var sum: u64 = 0;
    var it = positions.iterator();
    while (it.next()) |kv| {
        sum += checkPositions2(kv.value_ptr.*.items, &map);
    }

    return sum;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day8.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "day8" {
    try testing.expectEqual(14, try run(test_input, testing.allocator));
    try testing.expectEqual(34, try run2(test_input, testing.allocator));
}
