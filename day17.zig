const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\Register A: 729
    \\Register B: 0
    \\Register C: 0
    \\
    \\Program: 0,1,5,4,3,0
;

const test_input2 =
    \\Register A: 2024
    \\Register B: 0
    \\Register C: 0
    \\
    \\Program: 0,3,5,4,3,0
;

fn runProgram(program: []u64, a: u64, b: u64, c: u64, alloc: Allocator) ![]u64 {
    var pc: usize = 0;
    var reg_a = a;
    var reg_b = b;
    var reg_c = c;

    var output = std.ArrayList(u64).init(alloc);
    defer output.deinit();

    while (pc < program.len - 1) {
        const opcode = program[pc];
        const operand = program[pc + 1];
        const combo = switch (operand) {
            0...3 => operand,
            4 => reg_a,
            5 => reg_b,
            6 => reg_c,
            else => unreachable,
        };

        // print("{d} {d} {d}\n", .{ opcode, operand, combo });

        switch (opcode) {
            0 => {
                const num = reg_a;
                const den = std.math.pow(u64, 2, combo);
                reg_a = num / den;
            },
            1 => {
                reg_b = reg_b ^ operand;
            },
            2 => {
                reg_b = combo % 8;
            },
            3 => {
                if (reg_a != 0) {
                    pc = operand;
                    continue;
                }
            },
            4 => {
                reg_b = reg_b ^ reg_c;
            },
            5 => {
                try output.append(combo % 8);
            },
            6 => {
                const num = reg_a;
                const den = std.math.pow(u64, 2, combo);
                reg_b = num / den;
            },
            7 => {
                const num = reg_a;
                const den = std.math.pow(u64, 2, combo);
                reg_c = num / den;
            },
            else => unreachable,
        }
        pc += 2;
    }

    return output.toOwnedSlice();
}

fn runProgram2(program: []u64, a: *u64, b: *u64, c: *u64, alloc: Allocator) ![]u64 {
    var pc: usize = 0;
    var reg_a = a.*;
    var reg_b = b.*;
    var reg_c = c.*;

    var output = std.ArrayList(u64).init(alloc);
    defer output.deinit();

    print("A: {d}\n", .{reg_a});
    print("B: {d}\n", .{reg_b});
    print("C: {d}\n", .{reg_c});

    var operations = std.ArrayList([]u8).init(alloc);
    defer {
        for (operations.items) |item| {
            alloc.free(item);
        }
        operations.deinit();
    }

    while (pc < program.len - 1) {
        const opcode = program[pc];
        const operand = program[pc + 1];
        const combo = switch (operand) {
            0...3 => operand,
            4 => reg_a,
            5 => reg_b,
            6 => reg_c,
            else => unreachable,
        };
        const combo_str = switch (operand) {
            0...3 => std.fmt.allocPrint(alloc, "{d}", .{operand}),
            4 => std.fmt.allocPrint(alloc, "A", .{}),
            5 => std.fmt.allocPrint(alloc, "B", .{}),
            6 => std.fmt.allocPrint(alloc, "C", .{}),
            else => unreachable,
        };
        defer alloc.free(combo_str);

        print("\nopc: {d} lit:{d} com:{d}\n", .{ opcode, operand, combo });
        switch (opcode) {
            0 => {
                const num = reg_a;
                const den = std.math.pow(u64, 2, combo);
                // a >> combo
                reg_a = num / den;
                try operations.append(std.fmt.allocPrint(alloc, "A = A / 2^{s}", .{combo_str}));
            },
            1 => {
                reg_b = reg_b ^ operand;
                try operations.append(std.fmt.allocPrint(alloc, "B = B xor {d}", .{combo_str}));
            },
            2 => {
                reg_b = combo % 8;
                try operations.append(std.fmt.allocPrint(alloc, "B = {s} % 8", .{combo_str}));
            },
            3 => {
                if (reg_a != 0) {
                    pc = operand;
                    try operations.append(std.fmt.allocPrint(alloc, "jump({d})", .{operand}));
                    continue;
                }
            },
            4 => {
                reg_b = reg_b ^ reg_c;
                try operations.append(std.fmt.allocPrint(alloc, "B = B xor C", .{combo_str}));
            },
            5 => {
                try output.append(combo % 8);
                try operations.append(std.fmt.allocPrint(alloc, "output({s} % 8)", .{combo_str}));
            },
            6 => {
                const num = reg_a;
                const den = std.math.pow(u64, 2, combo);
                // b >> combo
                reg_b = num / den;
                try operations.append(std.fmt.allocPrint(alloc, "C = A / 2^{s}", .{combo_str}));
            },
            7 => {
                const num = reg_a;
                const den = std.math.pow(u64, 2, combo);
                // c >> combo
                reg_c = num / den;
                try operations.append(std.fmt.allocPrint(alloc, "C = A / 2^{s}", .{combo_str}));
            },
            else => unreachable,
        }
        print("A: {d}\n", .{reg_a});
        print("B: {d}\n", .{reg_b});
        print("C: {d}\n", .{reg_c});

        pc += 2;
    }

    a.* = reg_a;
    b.* = reg_b;
    c.* = reg_c;

    return output.toOwnedSlice();
}

fn run(input: []const u8, alloc: Allocator) ![]u8 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    const reg_a = try std.fmt.parseInt(u64, lines[0][12..], 10);
    const reg_b = try std.fmt.parseInt(u64, lines[1][12..], 10);
    const reg_c = try std.fmt.parseInt(u64, lines[2][12..], 10);

    // print("{d}\n{d}\n{d}\n", .{ reg_a, reg_b, reg_c });

    const program = try utils.toSlice(u64, lines[4][9..], ",", alloc);
    defer alloc.free(program);

    // print("{any}\n", .{program});

    const output = try runProgram(program, reg_a, reg_b, reg_c, alloc);
    defer alloc.free(output);

    var str = std.ArrayList(u8).init(alloc);
    defer str.deinit();

    for (output, 0..) |o, i| {
        const c: u8 = @intCast('0' + o);
        if (i > 0) {
            try str.append(',');
        }
        try str.append(c);
    }

    print("{s}\n", .{str.items});

    return str.toOwnedSlice();
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var reg_a = try std.fmt.parseInt(u64, lines[0][12..], 10);
    var reg_b = try std.fmt.parseInt(u64, lines[1][12..], 10);
    var reg_c = try std.fmt.parseInt(u64, lines[2][12..], 10);

    // print("{d}\n{d}\n{d}\n", .{ reg_a, reg_b, reg_c });

    const program = try utils.toSlice(u64, lines[4][9..], ",", alloc);
    defer alloc.free(program);

    // print("{any}\n", .{program});

    const output = try runProgram2(program, &reg_a, &reg_b, &reg_c, alloc);
    defer alloc.free(output);
    print("{any}\n", .{output});

    // var str = std.ArrayList(u8).init(alloc);
    // defer str.deinit();
    //
    // for (output, 0..) |o, i| {
    //     const c: u8 = @intCast('0' + o);
    //     if (i > 0) {
    //         try str.append(',');
    //     }
    //     try str.append(c);
    // }

    // print("{s}\n", .{str.items});

    return @intCast(lines.len);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day17.txt", alloc);

    print("{s}\n", .{try run(input, alloc)});
    // print("{d}\n", .{try run2(input, alloc)});
}

test "day17" {
    // const s1 = try run(test_input, testing.allocator);
    // defer testing.allocator.free(s1);

    // try testing.expect(std.mem.eql(u8, "4,6,3,5,6,3,5,2,1,0", s1));
    try testing.expectEqual(117440, try run2(test_input2, testing.allocator));
}
