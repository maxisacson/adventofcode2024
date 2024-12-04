const std = @import("std");
const readFile = @import("utils.zig").readFile;

const test_input =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;

const Grid = struct {
    rows: usize,
    cols: usize,
    data: []const u8,

    pub fn get(self: *const Grid, r: i32, c: i32) u8 {
        const index = c + r * @as(i32, @intCast(self.cols));
        if (c < 0 or c >= self.cols or r < 0 or r >= self.rows) {
            return 0;
        }
        return self.data[@intCast(index)];
    }

    pub fn check(self: *const Grid, r: i32, c: i32) u32 {
        const chars = [_]u8{ 'X', 'M', 'A', 'S' };
        var count: u32 = 0;

        // check forward
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r, c + k) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        // check backward
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r, c - k) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        // check up
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r - k, c) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        // chech down
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r + k, c) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        // check diagonal 0
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r + k, c + k) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        // check diagonal 1
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r + k, c - k) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        // check diagonal 2
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r - k, c + k) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        // check diagonal 3
        count += blk: {
            var maybe: bool = true;
            for (1..4) |i| {
                const k: i32 = @intCast(i);
                maybe = maybe and (self.get(r - k, c - k) == chars[i]);
            }
            break :blk if (maybe) 1 else 0;
        };

        return count;
    }

    pub fn check2(self: *const Grid, r: i32, c: i32) u32 {
        const chars = [_]u8{ 'M', 'A', 'S' };

        // check diagonal 0
        const pass0 = blk: {
            var maybe: bool = true;
            for (0..3) |i| {
                const k: i32 = @as(i32, @intCast(i)) - 1;
                maybe = maybe and (self.get(r + k, c + k) == chars[i]);
            }
            break :blk maybe;
        };

        // check diagonal 1
        const pass1 = blk: {
            var maybe: bool = true;
            for (0..3) |i| {
                const k: i32 = @as(i32, @intCast(i)) - 1;
                maybe = maybe and (self.get(r + k, c - k) == chars[i]);
            }
            break :blk maybe;
        };

        // check diagonal 2
        const pass2 = blk: {
            var maybe: bool = true;
            for (0..3) |i| {
                const k: i32 = @as(i32, @intCast(i)) - 1;
                maybe = maybe and (self.get(r - k, c + k) == chars[i]);
            }
            break :blk maybe;
        };

        // check diagonal 3
        const pass3 = blk: {
            var maybe: bool = true;
            for (0..3) |i| {
                const k: i32 = @as(i32, @intCast(i)) - 1;
                maybe = maybe and (self.get(r - k, c - k) == chars[i]);
            }
            break :blk maybe;
        };

        const pass = (pass0 or pass3) and (pass1 or pass2);

        return if (pass) 1 else 0;
    }
};

fn run(input: []const u8) !u32 {
    var row = std.mem.tokenize(u8, input, "\n");
    const cols = row.peek().?.len;

    var data = std.ArrayList(u8).init(std.heap.page_allocator);
    defer data.deinit();

    var rows: usize = 0;
    while (row.next()) |line| : (rows += 1) {
        try data.appendSlice(line);
    }

    const grid = Grid{
        .rows = rows,
        .cols = cols,
        .data = data.items,
    };

    var count: u32 = 0;
    for (0..grid.rows) |i| {
        for (0..grid.cols) |j| {
            const c = grid.get(@intCast(i), @intCast(j));
            if (c != 'X') {
                continue;
            }
            count += grid.check(@intCast(i), @intCast(j));
        }
    }

    return count;
}

fn run2(input: []const u8) !u32 {
    var row = std.mem.tokenize(u8, input, "\n");
    const cols = row.peek().?.len;

    var data = std.ArrayList(u8).init(std.heap.page_allocator);
    defer data.deinit();

    var rows: usize = 0;
    while (row.next()) |line| : (rows += 1) {
        try data.appendSlice(line);
    }

    const grid = Grid{
        .rows = rows,
        .cols = cols,
        .data = data.items,
    };

    var count: u32 = 0;
    for (0..grid.rows) |i| {
        for (0..grid.cols) |j| {
            const c = grid.get(@intCast(i), @intCast(j));
            if (c != 'A') {
                continue;
            }
            count += grid.check2(@intCast(i), @intCast(j));
        }
    }

    return count;
}

pub fn main() !void {
    const text = try readFile("day4.txt");
    const result = try run(text);
    std.debug.print("{d}\n", .{result});

    const result2 = try run2(text);
    std.debug.print("{d}\n", .{result2});
}

test "day4" {
    try std.testing.expectEqual(18, try run(test_input));
    try std.testing.expectEqual(9, try run2(test_input));
}
