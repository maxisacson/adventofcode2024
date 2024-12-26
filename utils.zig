const std = @import("std");
const fmt = std.fmt;
const Allocator = std.mem.Allocator;

pub fn readFile(filename: []const u8) ![]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();
    const text = try file.readToEndAlloc(std.heap.page_allocator, std.math.maxInt(usize));
    return text;
}

pub fn readFile2(filename: []const u8, allocator: Allocator) ![]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();
    const text = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    return text;
}

pub fn splitLines(input: []const u8, allocator: Allocator) ![][]const u8 {
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iter = std.mem.splitScalar(u8, input, '\n');
    while (iter.next()) |line| {
        if (line.len == 0 and iter.peek() == null) {
            break;
        }
        try lines.append(line);
    }

    return try lines.toOwnedSlice();
}

pub fn toSlice(comptime T: type, input: []const u8, sep: []const u8, allocator: Allocator) ![]T {
    var list = std.ArrayList(T).init(allocator);
    defer list.deinit();

    var iter = std.mem.tokenizeSequence(u8, input, sep);
    while (iter.next()) |token| {
        switch (@typeInfo(T)) {
            .Int => {
                try list.append(try std.fmt.parseInt(T, token, 10));
            },
            else => unreachable,
        }
    }

    return list.toOwnedSlice();
}

pub fn printLn(str: []const u8) void {
    std.debug.print("{s}\n", .{str});
}

pub const GridMapError = error{
    InvalidPosition,
    IndexOutOfRange,
};

pub const GridMap = struct {
    rows: i64 = 0,
    cols: i64 = 0,
    data: []u8,

    pub fn isValid(self: *const GridMap, i: i64, j: i64) bool {
        return (0 <= i and i < self.rows and 0 <= j and j < self.cols);
    }

    pub fn get(self: *const GridMap, i: i64, j: i64) GridMapError!u8 {
        if (!self.isValid(i, j)) {
            return GridMapError.InvalidPosition;
        }
        const index: usize = @intCast(j + i * self.cols);
        return self.data[index];
    }

    pub fn set(self: *GridMap, i: i64, j: i64, value: u8) GridMapError!void {
        if (!self.isValid(i, j)) {
            return GridMapError.InvalidPosition;
        }
        const index: usize = @intCast(j + i * self.cols);
        self.data[index] = value;
    }

    pub fn print(self: *const GridMap) void {
        const rows: usize = @intCast(self.rows);
        const cols: usize = @intCast(self.cols);
        for (0..rows) |row| {
            const start = row * cols;
            const stop = start + cols;
            std.debug.print("{s}\n", .{self.data[start..stop]});
        }
    }

    pub fn toIndex(self: *const GridMap, i: i64, j: i64) GridMapError!usize {
        if (!self.isValid(i, j)) {
            return GridMapError.InvalidPosition;
        }
        return @intCast(j + i * self.cols);
    }

    pub fn toRow(self: *const GridMap, index: usize) GridMapError!i64 {
        if (index >= self.data.len) {
            return GridMapError.IndexOutOfRange;
        }
        const row = index / @as(usize, @intCast(self.cols));
        return @intCast(row);
    }

    pub fn toCol(self: *const GridMap, index: usize) GridMapError!i64 {
        if (index >= self.data.len) {
            return GridMapError.IndexOutOfRange;
        }
        const col = index % @as(usize, @intCast(self.cols));
        return @intCast(col);
    }

    pub fn toPos(self: *const GridMap, index: usize) GridMapError![2]i64 {
        const row = try self.toRow(index);
        const col = try self.toCol(index);
        return .{ row, col };
    }

    pub fn reset(self: *GridMap, elem: u8) void {
        @memset(self.data, elem);
    }

    pub fn copy(self: *const GridMap, alloc: Allocator) Allocator.Error!GridMap {
        const data = try alloc.alloc(u8, self.data.len);
        std.mem.copyForwards(u8, data, self.data);
        return GridMap{
            .rows = self.rows,
            .cols = self.cols,
            .data = data,
        };
    }
};

pub fn createGridMap(lines: [][]const u8, alloc: Allocator) !GridMap {
    const rows = lines.len;
    const cols = lines[0].len;

    var data = try alloc.alloc(u8, rows * cols);
    for (lines, 0..) |line, i| {
        for (line, 0..) |c, j| {
            const index = j + cols * i;
            data[index] = c;
        }
    }

    return GridMap{
        .rows = @intCast(rows),
        .cols = @intCast(cols),
        .data = data,
    };
}

pub fn createEmptyGridMap(rows: usize, cols: usize, alloc: Allocator) !GridMap {
    return GridMap{
        .rows = @intCast(rows),
        .cols = @intCast(cols),
        .data = try alloc.alloc(u8, rows * cols),
    };
}

pub fn Point(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        pub fn sub(self: *const Point(T), other: Point(T)) Point(T) {
            return Point(T){
                .x = self.x - other.x,
                .y = self.y - other.y,
            };
        }

        pub fn add(self: *const Point(T), other: Point(T)) Point(T) {
            return Point(T){
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }
    };
}
