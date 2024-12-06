const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const readFile = @import("utils.zig").readFile;

const test_input =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

const Map = struct {
    rows: i32 = 0,
    cols: i32 = 0,
    data: []u8,

    pub fn isValid(self: *Map, x: i32, y: i32) bool {
        return (0 <= x and x < self.cols and 0 <= y and y < self.rows);
    }

    pub fn get(self: *Map, x: i32, y: i32) u8 {
        const index: usize = @intCast(x + y * self.cols);
        return self.data[index];
    }

    pub fn set(self: *Map, x: i32, y: i32, value: u8) void {
        const index: usize = @intCast(x + y * self.cols);
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

    pub fn reset(self: *Map) void {
        for (0..self.data.len) |i| {
            if (self.data[i] != '#') {
                self.data[i] = '.';
            }
        }
    }

    pub fn toIndex(self: *const Map, x: i32, y: i32) usize {
        return @intCast(x + y * self.cols);
    }
};

const GuardError = error{
    ToManyIterations,
    Looping,
    ExitMap,
};

fn dirToBit(dir: u8) u8 {
    return switch (dir) {
        '<' => 0b0001,
        'v' => 0b0010,
        '^' => 0b0100,
        '>' => 0b1000,
        else => unreachable,
    };
}

const Guard = struct {
    map: Map,
    x: i32,
    y: i32,
    dir: u8,
    visited: ?[]u8 = null,
    iterations: usize = 0,

    pub fn step(self: *Guard) bool {
        if (!self.map.isValid(self.x, self.y)) {
            return false;
        }
        const Pos = struct { x: i32, y: i32 };
        const next: Pos = switch (self.dir) {
            '<' => Pos{ .x = self.x - 1, .y = self.y },
            'v' => Pos{ .x = self.x, .y = self.y + 1 },
            '^' => Pos{ .x = self.x, .y = self.y - 1 },
            '>' => Pos{ .x = self.x + 1, .y = self.y },
            else => unreachable,
        };

        if (!self.map.isValid(next.x, next.y)) {
            self.map.set(self.x, self.y, 'X');
            self.x = next.x;
            self.y = next.y;
            return false;
        }

        const c = self.map.get(next.x, next.y);
        if (c == '#') {
            self.turn();
        } else {
            self.map.set(self.x, self.y, 'X');
            self.x = next.x;
            self.y = next.y;
        }
        return true;
    }

    pub fn loop(self: *Guard) GuardError!void {
        self.iterations += 1;
        if (self.iterations > 2 * self.map.rows * self.map.cols) {
            return GuardError.ToManyIterations;
        }

        if (!self.map.isValid(self.x, self.y)) {
            return GuardError.ExitMap;
        }

        const Pos = struct { x: i32, y: i32 };
        const next: Pos = switch (self.dir) {
            '<' => Pos{ .x = self.x - 1, .y = self.y },
            'v' => Pos{ .x = self.x, .y = self.y + 1 },
            '^' => Pos{ .x = self.x, .y = self.y - 1 },
            '>' => Pos{ .x = self.x + 1, .y = self.y },
            else => unreachable,
        };

        if (!self.map.isValid(next.x, next.y)) {
            self.map.set(self.x, self.y, self.dir);
            self.x = next.x;
            self.y = next.y;
            return GuardError.ExitMap;
        }

        const c = self.map.get(next.x, next.y);
        const b = dirToBit(self.dir);
        switch (c) {
            '#', 'O' => {
                self.map.set(self.x, self.y, self.dir);
                self.visited.?[self.map.toIndex(self.x, self.y)] |= b;
                self.turn();
            },
            '<', 'v', '^', '>' => {
                const visit = self.visited.?[self.map.toIndex(self.x, self.y)];
                if (visit & b > 0) {
                    return GuardError.Looping;
                }
                self.map.set(self.x, self.y, self.dir);
                self.visited.?[self.map.toIndex(self.x, self.y)] |= b;
                self.x = next.x;
                self.y = next.y;
            },
            else => {
                self.map.set(self.x, self.y, self.dir);
                self.visited.?[self.map.toIndex(self.x, self.y)] |= b;
                self.x = next.x;
                self.y = next.y;
            },
        }
    }

    pub fn turn(self: *Guard) void {
        self.dir = switch (self.dir) {
            '<' => '^',
            'v' => '<',
            '^' => '>',
            '>' => 'v',
            else => unreachable,
        };
    }
};

fn run(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var data = std.ArrayList(u8).init(alloc);

    var cols: i32 = 0;
    var rows: i32 = 0;
    var x: i32 = undefined;
    var y: i32 = undefined;
    var dir: u8 = undefined;

    var row = std.mem.tokenize(u8, input, "\n");
    while (row.next()) |line| : (rows += 1) {
        for (line, 0..) |c, i| {
            switch (c) {
                '^', '>', 'v', '<' => {
                    y = rows;
                    x = @intCast(i);
                    dir = c;
                },
                else => {},
            }
        }
        try data.appendSlice(line);
        cols = @intCast(line.len);
    }

    const map = Map{
        .rows = rows,
        .cols = cols,
        .data = data.items,
    };

    var guard = Guard{
        .x = x,
        .y = y,
        .dir = dir,
        .map = map,
    };

    while (guard.step()) {}

    var count: u32 = 0;
    for (map.data) |c| {
        count += if (c == 'X') 1 else 0;
    }

    return count;
}

fn run2(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var data = std.ArrayList(u8).init(alloc);

    var cols: i32 = 0;
    var rows: i32 = 0;
    var x: i32 = undefined;
    var y: i32 = undefined;
    var dir: u8 = undefined;

    var row = std.mem.tokenize(u8, input, "\n");
    while (row.next()) |line| : (rows += 1) {
        for (line, 0..) |c, i| {
            switch (c) {
                '^', '>', 'v', '<' => {
                    y = rows;
                    x = @intCast(i);
                    dir = c;
                },
                else => {},
            }
        }
        try data.appendSlice(line);
        cols = @intCast(line.len);
    }

    var map = Map{
        .rows = rows,
        .cols = cols,
        .data = data.items,
    };

    var count: u32 = 0;
    for (0..@intCast(map.rows)) |r| {
        for (0..@intCast(map.cols)) |c| {
            const i: i32 = @intCast(r);
            const j: i32 = @intCast(c);
            if (map.get(j, i) != '.') {
                continue;
            }

            map.set(j, i, 'O');

            var guard = Guard{
                .x = x,
                .y = y,
                .dir = dir,
                .map = map,
                .iterations = 0,
                .visited = try alloc.alloc(u8, @intCast(map.rows * map.cols)),
            };

            for (0..guard.visited.?.len) |ind| {
                guard.visited.?[ind] = 0;
            }

            local: while (guard.loop()) |_| {} else |err| {
                switch (err) {
                    GuardError.ToManyIterations => {
                        // count += 1;
                        return err;
                    },
                    GuardError.Looping => {
                        count += 1;
                    },
                    GuardError.ExitMap => {
                        break :local;
                    },
                }
            }

            map.reset();
            map.set(x, y, dir);
        }
    }

    return count;
}

pub fn main() !void {
    const text = try readFile("day6.txt");
    print("{d}\n", .{try run(text)});
    print("{d}\n", .{try run2(text)});
}

test "day6" {
    try testing.expectEqual(41, try run(test_input));
    try testing.expectEqual(6, try run2(test_input));
}
