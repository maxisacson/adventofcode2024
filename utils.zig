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
