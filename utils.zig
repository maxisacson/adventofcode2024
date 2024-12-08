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
