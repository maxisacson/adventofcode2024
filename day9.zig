const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input = "2333133121414131402";

fn parseDiskMap(dm: []const u8, alloc: Allocator) ![]?u64 {
    var blocks = std.ArrayList(?u64).init(alloc);
    defer blocks.deinit();

    var id: usize = 0;
    for (dm, 0..) |c, i| {
        const count: usize = @intCast(c - '0');
        if (i % 2 == 0) {
            // file
            for (0..count) |_| {
                try blocks.append(id);
            }
            id += 1;
        } else {
            // empty space
            for (0..count) |_| {
                try blocks.append(null);
            }
        }
    }

    return try blocks.toOwnedSlice();
}

fn compact(disk: []const ?u64, alloc: Allocator) ![]?u64 {
    var buffer = try alloc.alloc(?u64, disk.len);
    std.mem.copyForwards(?u64, buffer, disk);

    var j = buffer.len - 1;
    for (0..buffer.len) |i| {
        if (i == j) {
            break;
        }

        if (buffer[i] != null) {
            continue;
        }

        buffer[i] = buffer[j];
        buffer[j] = null;
        while (j > i + 1 and buffer[j] == null) {
            j -= 1;
        }
    }

    return buffer;
}

fn checksum(disk: []const ?u64) u64 {
    var sum: u64 = 0;
    for (disk, 0..) |d, i| {
        if (d == null) {
            continue;
        }
        sum += d.? * @as(u64, @intCast(i));
    }
    return sum;
}

fn defrag(disk: []const ?u64, alloc: Allocator) ![]?u64 {
    var free_space = std.ArrayList(u64).init(alloc);
    defer free_space.deinit();

    var free_index = std.ArrayList(usize).init(alloc);
    defer free_index.deinit();

    var next_free = std.ArrayList(?usize).init(alloc);
    defer next_free.deinit();

    var prev_free = std.ArrayList(?usize).init(alloc);
    defer prev_free.deinit();

    var file_index = std.ArrayList(u64).init(alloc);
    defer file_index.deinit();

    var file_size = std.ArrayList(u64).init(alloc);
    defer file_size.deinit();

    var buffer = try alloc.alloc(?u64, disk.len);
    std.mem.copyForwards(?u64, buffer, disk);
    buffer[0] = 0;

    var free_count: u64 = 0;
    var free_pos: usize = 0;
    var free_head: usize = 0;
    var current_file_size: usize = 0;
    var current_file_pos: usize = 0;
    for (disk, 0..) |d, i| {
        if (d == null) {
            if (free_count == 0) {
                free_pos = i;
            }
            free_count += 1;
        } else if (free_count > 0) {
            try free_space.append(free_count);
            try free_index.append(free_pos);
            if (free_head > 0) {
                next_free.items[free_head - 1] = free_head;
                try prev_free.append(free_head - 1);
                try next_free.append(null);
            } else {
                try prev_free.append(null);
                try next_free.append(null);
            }
            free_head += 1;
            free_count = 0;
        }

        if (d == null) {
            continue;
        }

        if (d != disk[current_file_pos]) {
            try file_index.append(current_file_pos);
            try file_size.append(current_file_size);
            current_file_size = 1;
            current_file_pos = i;
        } else {
            current_file_size += 1;
        }
    }
    try file_index.append(current_file_pos);
    try file_size.append(current_file_size);

    for (0..file_index.items.len) |k| {
        const i = file_index.items.len - 1 - k;
        const fi = file_index.items[i];
        const fs = file_size.items[i];

        for (free_space.items, 0..) |avail, j| {
            if (avail < fs) {
                continue;
            }
            if (free_index.items[j] > fi) {
                break;
            }
            for (0..fs) |offs| {
                buffer[free_index.items[j] + offs] = buffer[fi + offs];
                buffer[fi + offs] = null;
            }
            free_space.items[j] -= fs;
            free_index.items[j] += fs;
            if (free_space.items[j] == 0 and prev_free.items[j] != null) {
                next_free.items[prev_free.items[j].?] = next_free.items[j];
            }
            break;
        }
    }

    return buffer;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);
    const line = lines[0];

    const disk = try parseDiskMap(line, alloc);
    defer alloc.free(disk);

    const disk2 = try compact(disk, alloc);
    defer alloc.free(disk2);

    return checksum(disk2);
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);
    const line = lines[0];

    const disk = try parseDiskMap(line, alloc);
    defer alloc.free(disk);

    const disk2 = try defrag(disk, alloc);
    defer alloc.free(disk2);

    return checksum(disk2);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day9.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    print("{d}\n", .{try run2(input, alloc)});
}

test "day9" {
    try testing.expectEqual(1928, try run(test_input, testing.allocator));
    try testing.expectEqual(2858, try run2(test_input, testing.allocator));
}
