#!/bin/bash

if [ -z "$1" ]; then
    day="day$(date "+%-d")"
else
    day="day$1"
fi

filename="${day}.zig"

if [ -f "${filename}" ]; then
    exit
fi

cat <<EOF > "${filename}"
const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input = "";

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    return @intCast(lines.len);
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
    const input = try readFile("${day}.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "${day}" {
    try testing.expectEqual(0, try run(test_input, testing.allocator));
    try testing.expectEqual(0, try run2(test_input, testing.allocator));
}
EOF
