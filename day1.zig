const std = @import("std");

const testInput =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;

fn run(input: []const u8) !u32 {
    var left = std.ArrayList(i32).init(std.heap.page_allocator);
    defer left.deinit();

    var right = std.ArrayList(i32).init(std.heap.page_allocator);
    defer right.deinit();

    var row = std.mem.split(u8, input, "\n");
    while (row.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var col = std.mem.tokenize(u8, line, " ");
        try left.append(try std.fmt.parseInt(i32, col.next().?, 10));
        try right.append(try std.fmt.parseInt(i32, col.next().?, 10));
    }

    std.mem.sort(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (left.items, right.items) |l, r| {
        sum += @abs(l - r);
    }
    return sum;
}

fn run2(input: []const u8) !u32 {
    var left = std.ArrayList(u32).init(std.heap.page_allocator);
    defer left.deinit();

    var count = [_]u32{0} ** 100000;

    var row = std.mem.split(u8, input, "\n");
    while (row.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var col = std.mem.tokenize(u8, line, " ");
        try left.append(try std.fmt.parseInt(u32, col.next().?, 10));
        const i = try std.fmt.parseInt(u32, col.next().?, 10);
        count[i] += 1;
    }

    var sum: u32 = 0;
    for (left.items) |k| {
        sum += k * count[k];
    }
    return sum;
}

fn readFile(filename: []const u8) ![]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();
    const text = try file.readToEndAlloc(std.heap.page_allocator, std.math.maxInt(usize));
    return text;
}

pub fn main() !void {
    const text = try readFile("day1.txt");
    const result = try run(text);
    std.debug.print("{d}\n", .{result});

    const result2 = try run2(text);
    std.debug.print("{d}\n", .{result2});
}

test "day1" {
    const text: []const u8 = std.mem.sliceTo(testInput, 0);
    try std.testing.expectEqual(try run(text), 11);
    try std.testing.expectEqual(try run2(text), 31);
}
