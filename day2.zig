const std = @import("std");

const testInput =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

fn run(input: []const u8) !u32 {
    var count: u32 = 0;
    var row = std.mem.split(u8, input, "\n");
    while (row.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var col = std.mem.tokenize(u8, line, " ");

        var p: i32 = try std.fmt.parseInt(i32, col.next().?, 10);
        var diff: i32 = 0;

        count += while (col.next()) |c| {
            const n = try std.fmt.parseInt(i32, c, 10);
            if (@abs(n - p) < 1 or @abs(n - p) > 3 or (n - p) * diff < 0) {
                break 0;
            }
            diff = n - p;
            p = n;
        } else 1;
    }

    return count;
}

fn isBad(n: i32, m: i32, dir: i32) bool {
    return @abs(n - m) < 1 or @abs(n - m) > 3 or (n - m) * dir < 0;
}

fn isSafe(arr: []i32) bool {
    const dir = arr[1] - arr[0];
    for (1..arr.len) |i| {
        if (isBad(arr[i], arr[i - 1], dir)) {
            return false;
        }
    }
    return true;
}

fn checkAll(arr: []i32) std.mem.Allocator.Error!bool {
    if (isSafe(arr)) {
        return true;
    }
    for (0..arr.len) |skip| {
        var tmp = std.ArrayList(i32).init(std.heap.page_allocator);
        defer tmp.deinit();

        if (skip == 0) {
            try tmp.appendSlice(arr[1..]);
        } else if (skip == arr.len - 1) {
            try tmp.appendSlice(arr[0 .. arr.len - 1]);
        } else {
            try tmp.appendSlice(arr[0..skip]);
            try tmp.appendSlice(arr[skip + 1 ..]);
        }
        if (isSafe(tmp.items)) {
            return true;
        }
    }
    return false;
}

fn run2(input: []const u8) !u32 {
    var count: u32 = 0;
    var row = std.mem.split(u8, input, "\n");
    while (row.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var col = std.mem.tokenize(u8, line, " ");
        var arr = std.ArrayList(i32).init(std.heap.page_allocator);
        defer arr.deinit();

        while (col.next()) |c| {
            const n = try std.fmt.parseInt(i32, c, 10);
            try arr.append(n);
        }

        if (try checkAll(arr.items)) {
            count += 1;
        }
    }

    return count;
}

fn readFile(filename: []const u8) ![]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();
    const text = try file.readToEndAlloc(std.heap.page_allocator, std.math.maxInt(usize));
    return text;
}

pub fn main() !void {
    const text = try readFile("day2.txt");
    const result = try run(text);
    std.debug.print("{d}\n", .{result});

    const result2 = try run2(text);
    std.debug.print("{d}\n", .{result2});
}

test "day2" {
    const text: []const u8 = std.mem.sliceTo(testInput, 0);
    try std.testing.expectEqual(try run(text), 2);
    try std.testing.expectEqual(try run2(text), 4);
}
