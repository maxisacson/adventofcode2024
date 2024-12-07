const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

const readFile = @import("utils.zig").readFile;

const test_input =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

fn checkLine(line: []const u8, rules: *const std.StringHashMap(std.ArrayList([]const u8))) !i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var forbidden = std.StringHashMap(void).init(alloc);
    defer forbidden.deinit();

    var numbers = std.ArrayList(i32).init(alloc);
    defer numbers.deinit();

    var iter = std.mem.tokenize(u8, line, ",");
    while (iter.next()) |n| {
        const x = try std.fmt.parseInt(i32, n, 10);
        try numbers.append(x);
    }

    iter.reset();
    while (iter.next()) |n| {
        if (forbidden.contains(n)) {
            return 0;
        }

        if (rules.*.contains(n)) {
            const items = rules.*.getPtr(n).?.*.items;
            for (items) |item| {
                _ = try forbidden.getOrPutValue(item, {});
            }
        }
    }

    return numbers.items[@divTrunc(numbers.items.len, 2)];
}

fn fixLine(line: []const u8, rules: *const std.StringHashMap(std.ArrayList([]const u8))) !i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var indices = std.StringHashMap(usize).init(alloc);
    defer indices.deinit();

    var forbidden = std.StringHashMap(void).init(alloc);
    defer forbidden.deinit();

    var numbers = std.ArrayList(i32).init(alloc);
    defer numbers.deinit();

    var bad = std.ArrayList(bool).init(alloc);
    defer bad.deinit();

    var iter = std.mem.tokenize(u8, line, ",");
    while (iter.next()) |n| {
        const x = try std.fmt.parseInt(i32, n, 10);
        try numbers.append(x);
        try bad.append(false);
    }

    iter.reset();
    while (iter.next()) |n| {
        if (forbidden.contains(n)) {
            return 0;
        }

        if (rules.*.contains(n)) {
            const items = rules.*.getPtr(n).?.*.items;
            for (items) |item| {
                _ = try forbidden.getOrPutValue(item, {});
            }
        }
    }
}

fn run(input: []const u8) !i32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var row = std.mem.split(u8, input, "\n");

    // parse rules
    var rules = std.StringHashMap(std.ArrayList([]const u8)).init(alloc);

    while (row.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var col = std.mem.tokenize(u8, line, "|");
        const a = col.next().?;
        const b = col.next().?;
        if (rules.contains(b)) {
            const list = rules.getPtr(b).?;
            try list.*.append(a);
        } else {
            var list = std.ArrayList([]const u8).init(alloc);
            try list.append(a);
            try rules.put(b, list);
        }
    }

    // var iter = rules.iterator();
    // while (iter.next()) |rule| {
    //     print("{s}: ", .{rule.key_ptr.*});
    //     for (rule.value_ptr.*.items) |item| {
    //         print(" {s}", .{item});
    //     }
    //     print("\n", .{});
    // }

    // parse updates
    var sum: i32 = 0;
    while (row.next()) |line| {
        if (line.len == 0) {
            break;
        }
        sum += try checkLine(line, &rules);
    }

    return sum;
}

fn run2(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var row = std.mem.split(u8, input, "\n");

    // parse rules
    var rules = std.StringHashMap(std.ArrayList([]const u8)).init(alloc);

    while (row.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var col = std.mem.tokenize(u8, line, "|");
        const a = col.next().?;
        const b = col.next().?;
        if (rules.contains(b)) {
            const list = rules.getPtr(b).?;
            try list.*.append(a);
        } else {
            var list = std.ArrayList([]const u8).init(alloc);
            try list.append(a);
            try rules.put(b, list);
        }
    }

    // var iter = rules.iterator();
    // while (iter.next()) |rule| {
    //     print("{s}: ", .{rule.key_ptr.*});
    //     for (rule.value_ptr.*.items) |item| {
    //         print(" {s}", .{item});
    //     }
    //     print("\n", .{});
    // }

    // parse updates
    var sum: i32 = 0;
    while (row.next()) |line| {
        if (line.len == 0) {
            break;
        }
        if (try !checkLine(line, &rules)) {
            sum += try fixLine(line, &rules);
        }
    }

    // return sum;
    return @intCast(input.len);
}

pub fn main() !void {
    const text = try readFile("day5.txt");
    print("{d}\n", .{try run(text)});
    print("{d}\n", .{try run2(text)});
}

test "day5" {
    try testing.expectEqual(143, try run(test_input));
    // try testing.expectEqual(123, try run2(test_input));

    const text = try readFile("day5.txt");
    try testing.expectEqual(4662, try run(text));
    try testing.expectEqual(5900, try run2(text));
}
