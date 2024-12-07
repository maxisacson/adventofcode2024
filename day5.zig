const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

const utils = @import("utils.zig");
const readFile = utils.readFile;

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

fn compare(a: i32, b: i32, rules: *const std.AutoHashMap(Pair, i32)) i32 {
    const ab = Pair{ .a = a, .b = b };

    if (rules.*.contains(ab)) {
        return rules.*.get(ab).?;
    }

    return 0;
}

fn checkSorted(array: []i32, rules: *const std.AutoHashMap(Pair, i32)) bool {
    for (0..array.len - 1) |i| {
        if (compare(array[i], array[i + 1], rules) == 1) {
            return false;
        }
    }
    return true;
}

fn sort(array: []i32, rules: *const std.AutoHashMap(Pair, i32)) void {
    var sorted = false;
    while (!sorted) {
        sorted = true;
        for (0..array.len - 1) |i| {
            if (compare(array[i], array[i + 1], rules) == 1) {
                sorted = false;
                const tmp = array[i + 1];
                array[i + 1] = array[i];
                array[i] = tmp;
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

const Pair = struct {
    a: i32,
    b: i32,
};

fn run2(input: []const u8) !i32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var row = std.mem.split(u8, input, "\n");

    // parse rules
    var sort_rules = std.AutoHashMap(Pair, i32).init(alloc);

    while (row.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var col = std.mem.tokenize(u8, line, "|");
        const ab = Pair{
            .a = try std.fmt.parseInt(i32, col.next().?, 10),
            .b = try std.fmt.parseInt(i32, col.next().?, 10),
        };
        const ba = Pair{ .a = ab.b, .b = ab.a };
        try sort_rules.put(ab, -1);
        try sort_rules.put(ba, 1);
    }

    // parse updates
    var sum: i32 = 0;
    while (row.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const numbers = try utils.toSlice(i32, line, ",", alloc);
        if (!checkSorted(numbers, &sort_rules)) {
            sort(numbers, &sort_rules);
            sum += numbers[@divTrunc(numbers.len, 2)];
        }
    }

    return sum;
}

pub fn main() !void {
    const text = try readFile("day5.txt");
    print("{d}\n", .{try run(text)});
    print("{d}\n", .{try run2(text)});
}

test "day5" {
    try testing.expectEqual(143, try run(test_input));
    try testing.expectEqual(123, try run2(test_input));

    const text = try readFile("day5.txt");
    try testing.expectEqual(4662, try run(text));
    try testing.expectEqual(5900, try run2(text));
}
