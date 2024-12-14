const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\p=0,4 v=3,-3
    \\p=6,3 v=-1,-3
    \\p=10,3 v=-1,2
    \\p=2,0 v=2,-1
    \\p=0,0 v=1,3
    \\p=3,0 v=-2,-2
    \\p=7,6 v=-1,-3
    \\p=3,0 v=-1,-2
    \\p=9,3 v=2,3
    \\p=7,3 v=-1,2
    \\p=2,4 v=2,-3
    \\p=9,5 v=-3,-3
;

const Room = struct {
    width: i64,
    height: i64,
};

const Robot = struct {
    pos: [2]i64,
    vel: [2]i64,

    pub fn move(self: *Robot, room: Room) void {
        self.pos[0] = @mod(self.vel[0] + self.pos[0], room.width);
        self.pos[1] = @mod(self.vel[1] + self.pos[1], room.height);
    }
};

fn run(input: []const u8, width: i64, height: i64, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var robots = std.ArrayList(Robot).init(alloc);
    defer robots.deinit();

    for (lines) |line| {
        var split = std.mem.split(u8, line, " ");

        var piter = std.mem.split(u8, split.next().?[2..], ",");
        const x = try std.fmt.parseInt(i64, piter.next().?, 10);
        const y = try std.fmt.parseInt(i64, piter.next().?, 10);

        var viter = std.mem.split(u8, split.next().?[2..], ",");
        const u = try std.fmt.parseInt(i64, viter.next().?, 10);
        const v = try std.fmt.parseInt(i64, viter.next().?, 10);

        const robot = Robot{
            .pos = .{ x, y },
            .vel = .{ u, v },
        };
        try robots.append(robot);
    }

    const room = Room{ .width = width, .height = height };

    for (0..100) |_| {
        for (0..robots.items.len) |i| {
            robots.items[i].move(room);
        }
    }

    var count = [2][2]u64{ .{ 0, 0 }, .{ 0, 0 } };
    for (robots.items) |robot| {
        const x = robot.pos[0];
        const y = robot.pos[1];

        var i: usize = undefined;
        var j: usize = undefined;

        if (x < @divTrunc(width, 2)) {
            j = 0;
        } else if (x > @divTrunc(width, 2)) {
            j = 1;
        } else {
            continue;
        }

        if (y < @divTrunc(height, 2)) {
            i = 0;
        } else if (y > @divTrunc(height, 2)) {
            i = 1;
        } else {
            continue;
        }

        count[i][j] += 1;
    }

    const result = count[0][0] * count[0][1] * count[1][0] * count[1][1];

    return result;
}

fn countH(map: *utils.GridMap) !u64 {
    const rows: usize = @intCast(map.*.rows);
    const cols: usize = @intCast(map.*.cols);
    var maximum: usize = 0;
    var count: usize = 0;
    for (0..rows) |row| {
        count = 0;
        for (0..cols) |col| {
            const tile = try map.*.get(@intCast(row), @intCast(col));
            if (tile == '.') {
                if (count > maximum) {
                    maximum = count;
                }
                count = 0;
                continue;
            }
            count += 1;
        }
        if (count > maximum) {
            maximum = count;
        }
        count = 0;
    }

    return maximum;
}

fn run2(input: []const u8, width: i64, height: i64, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var robots = std.ArrayList(Robot).init(alloc);
    defer robots.deinit();

    const map_data = try alloc.alloc(u8, @intCast(width * height));
    defer alloc.free(map_data);

    var map = utils.GridMap{
        .rows = height,
        .cols = width,
        .data = map_data,
    };
    const reset: u8 = '.';
    map.reset(reset);

    for (lines) |line| {
        var split = std.mem.split(u8, line, " ");

        var piter = std.mem.split(u8, split.next().?[2..], ",");
        const x = try std.fmt.parseInt(i64, piter.next().?, 10);
        const y = try std.fmt.parseInt(i64, piter.next().?, 10);

        var viter = std.mem.split(u8, split.next().?[2..], ",");
        const u = try std.fmt.parseInt(i64, viter.next().?, 10);
        const v = try std.fmt.parseInt(i64, viter.next().?, 10);

        const robot = Robot{
            .pos = .{ x, y },
            .vel = .{ u, v },
        };
        try robots.append(robot);
        if (try map.get(y, x) == reset) {
            try map.set(y, x, '1');
        } else {
            try map.set(y, x, try map.get(y, x) + 1);
        }
    }

    const room = Room{ .width = width, .height = height };

    var seconds: usize = 0;
    while (true) : (seconds += 1) {
        const count = try countH(&map);
        if (count > 10) {
            map.print();
            break;
        }

        map.reset(reset);
        for (0..robots.items.len) |i| {
            robots.items[i].move(room);

            const x = robots.items[i].pos[0];
            const y = robots.items[i].pos[1];

            if (try map.get(y, x) == reset) {
                try map.set(y, x, '1');
            } else {
                try map.set(y, x, try map.get(y, x) + 1);
            }
        }
    }

    return seconds;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day14.txt", alloc);

    print("{d}\n", .{try run(input, 101, 103, alloc)});
    print("{d}\n", .{try run2(input, 101, 103, alloc)});
}

test "day14" {
    try testing.expectEqual(12, try run(test_input, 11, 7, testing.allocator));
}
