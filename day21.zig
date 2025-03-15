const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\029A
    \\980A
    \\179A
    \\456A
    \\379A
;

fn getNumSym(pos: utils.Point(i64)) u8 {
    const pad = [_][3]u8{
        [_]u8{ ' ', '0', 'A' },
        [_]u8{ '1', '2', '3' },
        [_]u8{ '4', '5', '6' },
        [_]u8{ '7', '8', '9' },
    };

    return pad[@intCast(pos.y)][@intCast(pos.x)];
}

fn getDirSym(pos: utils.Point(i64)) u8 {
    const pad = [_][3]u8{
        [_]u8{ '<', 'v', '>' },
        [_]u8{ ' ', '^', 'A' },
    };

    return pad[@intCast(pos.y)][@intCast(pos.x)];
}

fn robot(moves: []const u8, start: utils.Point(i64), alloc: Allocator, comptime F: anytype) ![]u8 {
    var pos = start;

    var code = std.ArrayList(u8).init(alloc);
    defer code.deinit();

    for (moves) |m| {
        if (F(pos) == ' ') {
            unreachable;
        }

        if (m == 'A') {
            try code.append(F(pos));
            continue;
        }

        const step = switch (m) {
            '<' => utils.Point(i64){ .x = -1, .y = 0 },
            'v' => utils.Point(i64){ .x = 0, .y = -1 },
            '^' => utils.Point(i64){ .x = 0, .y = 1 },
            '>' => utils.Point(i64){ .x = 1, .y = 0 },
            else => unreachable,
        };

        pos = pos.add(step);
    }

    return code.toOwnedSlice();
}

fn getNumPos(n: u8) utils.Point(i64) {
    // Keypad:
    // 789
    // 456
    // 123
    //  0A

    var point = utils.Point(i64){ .x = 0, .y = 0 };
    switch (n) {
        '7'...'9' => point.y = 3,
        '4'...'6' => point.y = 2,
        '1'...'3' => point.y = 1,
        '0', 'A' => point.y = 0,
        else => unreachable,
    }
    switch (n) {
        '1', '4', '7' => point.x = 0,
        '0', '2', '5', '8' => point.x = 1,
        'A', '3', '6', '9' => point.x = 2,
        else => unreachable,
    }
    return point;
}

fn getDirPos(n: u8) utils.Point(i64) {
    // Keypad:
    //  ^A
    // <v>

    var point = utils.Point(i64){ .x = 0, .y = 0 };
    switch (n) {
        '^', 'A' => point.y = 1,
        '<', 'v', '>' => point.y = 0,
        else => unreachable,
    }
    switch (n) {
        '<' => point.x = 0,
        '^', 'v' => point.x = 1,
        '>', 'A' => point.x = 2,
        else => unreachable,
    }
    return point;
}

fn getMovesNum(code: []const u8, alloc: Allocator) ![]u8 {
    var pos = getNumPos('A');

    var moves = std.ArrayList(u8).init(alloc);
    defer moves.deinit();

    for (code) |c| {
        const target = getNumPos(c);
        const delta = target.sub(pos);
        const h: u8 = if (delta.x < 0) '<' else '>';
        const v: u8 = if (delta.y < 0) 'v' else '^';

        if (pos.x == 0 and pos.y + delta.y == 0) {
            for (0..@abs(delta.x)) |_| {
                try moves.append(h);
            }
            for (0..@abs(delta.y)) |_| {
                try moves.append(v);
            }
        } else if (pos.y == 0 and pos.x + delta.x == 0) {
            for (0..@abs(delta.y)) |_| {
                try moves.append(v);
            }
            for (0..@abs(delta.x)) |_| {
                try moves.append(h);
            }
        } else {
            if (delta.x > 0 and delta.y < 0) {
                for (0..@abs(delta.x)) |_| {
                    try moves.append(h);
                }
                for (0..@abs(delta.y)) |_| {
                    try moves.append(v);
                }
            } else {
                for (0..@abs(delta.y)) |_| {
                    try moves.append(v);
                }
                for (0..@abs(delta.x)) |_| {
                    try moves.append(h);
                }
            }
        }

        try moves.append('A');
        pos = target;
    }

    return moves.toOwnedSlice();
}

// fn genMoves(

fn getMovesDir(code: []const u8, alloc: Allocator) ![]u8 {
    var pos = getDirPos('A');

    var moves = std.ArrayList(u8).init(alloc);
    defer moves.deinit();

    for (code) |c| {
        const target = getDirPos(c);
        const diff = target.sub(pos);
        const h: u8 = if (diff.x < 0) '<' else '>';
        const v: u8 = if (diff.y < 0) 'v' else '^';

        if (pos.x != 0 and pos.y != 1) {
            if (diff.x < 0 and diff.y < 0) {
                for (0..@abs(diff.y)) |_| {
                    try moves.append(v);
                }
                for (0..@abs(diff.x)) |_| {
                    try moves.append(h);
                }
            } else if (diff.x > 0 and diff.y < 0) {
                for (0..@abs(diff.x)) |_| {
                    try moves.append(h);
                }
                for (0..@abs(diff.y)) |_| {
                    try moves.append(v);
                }
            } else if (diff.x < 0 and diff.y > 0) {
                for (0..@abs(diff.y)) |_| {
                    try moves.append(v);
                }
                for (0..@abs(diff.x)) |_| {
                    try moves.append(h);
                }
            } else {
                for (0..@abs(diff.x)) |_| {
                    try moves.append(h);
                }
                for (0..@abs(diff.y)) |_| {
                    try moves.append(v);
                }
            }
        } else if (pos.x == 0) {
            for (0..@abs(diff.x)) |_| {
                try moves.append(h);
            }
            for (0..@abs(diff.y)) |_| {
                try moves.append(v);
            }
        } else if (pos.y == 1) {
            for (0..@abs(diff.y)) |_| {
                try moves.append(v);
            }
            for (0..@abs(diff.x)) |_| {
                try moves.append(h);
            }
        } else {
            unreachable;
        }

        try moves.append('A');
        pos = target;
    }

    return moves.toOwnedSlice();
}

// v <
// > v
// ^ <

const Order = enum { XY, YX };

fn genMoves(delta: utils.Point(i64), order: Order, alloc: Allocator) ![]u8 {
    var moves = std.ArrayList(u8).init(alloc);
    defer moves.deinit();

    const h: u8 = if (delta.x < 0) '<' else '>';
    const v: u8 = if (delta.y < 0) 'v' else '^';

    switch (order) {
        Order.XY => {
            for (0..@abs(delta.x)) |_| {
                try moves.append(h);
            }
            for (0..@abs(delta.y)) |_| {
                try moves.append(v);
            }
        },
        Order.YX => {
            for (0..@abs(delta.y)) |_| {
                try moves.append(v);
            }
            for (0..@abs(delta.x)) |_| {
                try moves.append(h);
            }
        },
    }

    return moves.toOwnedSlice();
}

fn genDirMovesRec(start: u8, end: u8, depth: u64, alloc: Allocator) ![]u8 {
    const pos = getDirPos(start);
    const target = getDirPos(end);

    var moves = std.ArrayList(u8).init(alloc);
    defer moves.deinit();

    if (depth == 0) {
        return moves.toOwnedSlice();
    }

    const delta = target.sub(pos);

    if (pos.x == 0 and pos.y + delta.y == 1) {
        const tmp = try genMoves(delta, Order.XY, alloc);
        defer alloc.free(tmp);

        const tmp_moves = try genDirMoves(tmp, depth - 1, alloc);
        defer alloc.free(tmp_moves);

        try moves.appendSlice(tmp_moves);
    } else if (pos.y == 1 and pos.x + delta.x == 0) {
        const tmp = try genMoves(delta, Order.YX, alloc);
        defer alloc.free(tmp);

        const tmp_moves = try genDirMoves(tmp, depth - 1, alloc);
        defer alloc.free(tmp_moves);

        try moves.appendSlice(tmp_moves);
    } else {
        const tmp1 = try genMoves(delta, Order.XY, alloc);
        defer alloc.free(tmp1);
        const tmp2 = try genMoves(delta, Order.YX, alloc);
        defer alloc.free(tmp2);
        const tmp1_moves = try genDirMoves(tmp1, depth - 1, alloc);
        defer alloc.free(tmp1_moves);
        const tmp2_moves = try genDirMoves(tmp2, depth - 1, alloc);
        defer alloc.free(tmp2_moves);

        if (tmp2_moves.len < tmp1_moves.len) {
            try moves.appendSlice(tmp2_moves);
        } else {
            try moves.appendSlice(tmp1_moves);
        }
    }

    return moves.toOwnedSlice();
}

fn genDirMoves(seq: []const u8, depth: u64, alloc: Allocator) Allocator.Error![]u8 {
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    for (0..seq.len) |i| {
        const moves = if (i == 0)
            try genDirMovesRec('A', seq[i], depth, alloc)
        else
            try genDirMovesRec(seq[i - 1], seq[i], depth, alloc);
        try list.appendSlice(moves);
    }

    return list.toOwnedSlice();
}

fn genNumMoves(start: u8, end: u8, alloc: Allocator) ![]u8 {
    const pos = getNumPos(start);
    const target = getNumPos(end);

    var moves = std.ArrayList(u8).init(alloc);
    defer moves.deinit();

    const delta = target.sub(pos);

    if (pos.x == 0 and pos.y + delta.y == 0) {
        const tmp = try genMoves(delta, Order.XY, alloc);
        defer alloc.free(tmp);
        const tmp_moves = try genDirMoves(tmp, 2, alloc);
        defer alloc.free(tmp_moves);
        try moves.appendSlice(tmp_moves);
    } else if (pos.y == 0 and pos.x + delta.x == 0) {
        const tmp = try genMoves(delta, Order.YX, alloc);
        defer alloc.free(tmp);
        const tmp_moves = try genDirMoves(tmp, 2, alloc);
        defer alloc.free(tmp_moves);
        try moves.appendSlice(tmp_moves);
    } else {
        const tmp1 = try genMoves(delta, Order.XY, alloc);
        defer alloc.free(tmp1);
        const tmp2 = try genMoves(delta, Order.YX, alloc);
        defer alloc.free(tmp2);
        const tmp1_moves = try genDirMoves(tmp1, 2, alloc);
        defer alloc.free(tmp1_moves);
        const tmp2_moves = try genDirMoves(tmp2, 2, alloc);
        defer alloc.free(tmp2_moves);

        if (tmp2_moves.len < tmp1_moves.len) {
            try moves.appendSlice(tmp2_moves);
        } else {
            try moves.appendSlice(tmp1_moves);
        }
    }

    print("{any}\n", .{moves.items});
    return moves.toOwnedSlice();
}

fn genBestMoves(code: []const u8, alloc: Allocator) ![]u8 {
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    for (0..code.len) |i| {
        const moves = if (i == 0)
            try genNumMoves('A', code[i], alloc)
        else
            try genNumMoves(code[i - 1], code[i], alloc);
        try list.appendSlice(moves);
    }

    return list.toOwnedSlice();
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var sum: u64 = 0;
    // const code = lines[4];
    for (lines) |code| {
        // const moves = try getMovesNum(code, alloc);
        // defer alloc.free(moves);
        //
        // const moves2 = try getMovesDir(moves, alloc);
        // defer alloc.free(moves2);
        //
        // const moves3 = try getMovesDir(moves2, alloc);
        // defer alloc.free(moves3);
        //
        // // print("{s}: {s}\n", .{ code, moves3 });
        // // print("      {s}\n", .{moves2});
        // // print("      {s}\n", .{moves});
        // // print("      {s}\n", .{code});
        // print("{d} {d}\n", .{ moves3.len, n });

        const moves = try genBestMoves(code, alloc);
        printLn(moves);

        const n = std.fmt.parseInt(u64, code[0..3], 10) catch 0;
        sum += n * moves.len;
    }

    // const code2 = try robot(moves3, getDirPos('A'), alloc, getDirSym);
    // const code1 = try robot(code2, getDirPos('A'), alloc, getDirSym);
    // const code0 = try robot(code1, getNumPos('A'), alloc, getNumSym);
    //
    // defer {
    //     alloc.free(code0);
    //     alloc.free(code1);
    //     alloc.free(code2);
    // }
    //
    // print("{s}\n", .{moves3});
    // print("{s}\n", .{code2});
    // print("{s}\n", .{code1});
    // print("{s}\n", .{code0});
    return sum;
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    return @intCast(lines.len);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day21.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    // print("{d}\n", .{try run2(input, alloc)});
}

test "day21" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    try testing.expectEqual(126384, try run(test_input, alloc));
    // try testing.expectEqual(0, try run2(test_input, testing.allocator));
}
