const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");
const print = std.debug.print;
const printLn = utils.printLn;
const readFile = utils.readFile2;
const Allocator = std.mem.Allocator;

const test_input =
    \\1
    \\10
    \\100
    \\2024
;

const test_input2 =
    \\1
    \\2
    \\3
    \\2024
;

fn next(n: u64) u64 {
    var k = n;

    k ^= k << 6;
    k %= 16777216;

    k ^= k >> 5;
    k %= 16777216;

    k ^= k << 11;
    k %= 16777216;

    return k;
}

fn run(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var sum: u64 = 0;
    for (lines) |line| {
        var n = try std.fmt.parseInt(u64, line, 10);
        for (0..2000) |_| {
            n = next(n);
        }
        sum += n;
    }

    return sum;
}

fn push(delta: []i64, x: i64) void {
    for (1..delta.len) |i| {
        delta[i - 1] = delta[i];
    }
    delta[delta.len - 1] = x;
}

const KeyType = [4]i64;
const Location = struct { seller: usize, time: usize, price: i64 };
// const MapType = std.AutoHashMap(KeyType, i64);
const MapType = std.AutoHashMap(KeyType, Location);
const CacheType = std.AutoHashMap(KeyType, u64);
const ListType = std.ArrayList(MapType);

fn getBestPriceFor(key: KeyType, list: ListType, cache: *CacheType) !u64 {
    if (cache.contains(key)) {
        return cache.get(key).?;
    }

    var sum: u64 = 0;
    for (list.items) |map| {
        const val = map.get(key);
        sum += @intCast(val orelse 0);
    }

    try cache.put(key, sum);
    return sum;
}

const Result = struct {
    price: u64,
    key: KeyType,
    sellers: []usize,
    times: []usize,
};

fn getBestPrice(list: ListType, alloc: Allocator) !Result {
    var cache = CacheType.init(alloc);
    defer cache.deinit();

    // var set = std.AutoHashMap(KeyType, void).init(alloc);
    // defer set.deinit();
    //
    // for (list.items) |map| {
    //     var iter = map.iterator();
    //     while (iter.next()) |kv| {
    //         const key = kv.key_ptr.*;
    //         try set.put(key, {});
    //     }
    // }
    //
    // var iter = set.keyIterator();
    // var best: u64 = 0;
    // var best_key: KeyType = undefined;
    // while (iter.next()) |k| {
    //     const price = try getBestPriceFor(k.*, list, &cache);
    //     if (price > best) {
    //         best = price;
    //         best_key = k.*;
    //     }
    // }
    // print("{any}\n", .{best_key});
    // return best;

    var best: u64 = 0;
    var best_key: KeyType = undefined;
    var best_list: usize = undefined;
    for (list.items, 0..) |map, i| {
        var iter = map.iterator();
        while (iter.next()) |kv| {
            const key = kv.key_ptr.*;
            // if (key[key.len - 1] <= 0) {
            //     continue;
            // }
            const current = try getBestPriceFor(key, list, &cache);
            if (current > best) {
                best = current;
                best_key = key;
                best_list = i;
            }
        }
    }

    print("{d}:  {any}\n", .{ best_list, best_key });
    return Result{
        .price = best,
        .key = best_key,
    };
}

fn run2(input: []const u8, alloc: Allocator) !u64 {
    const lines = try utils.splitLines(input, alloc);
    defer alloc.free(lines);

    var list = ListType.init(alloc);
    defer list.deinit();
    defer {
        for (list.items, 0..) |_, i| {
            list.items[i].deinit();
        }
    }

    var histories = std.ArrayList([2000]i64).init(alloc);
    defer histories.deinit();

    const key = KeyType{ 0, 2, 0, 0 };
    // const key = KeyType{ -2, 1, -1, 3 };
    var sum: i64 = 0;
    for (lines, 0..) |line, j| {
        // var n: u64 = 123;
        var n = try std.fmt.parseInt(u64, line, 10);

        var delta = [_]i64{undefined} ** 4;
        var map = MapType.init(alloc);
        var price: i64 = 0;

        var p: i64 = @intCast(n % 10);
        var history = [_]i64{undefined} ** 2000;
        for (0..2000) |i| {
            n = next(n);
            const p_next: i64 = @intCast(n % 10);
            push(&delta, p_next - p);
            p = p_next;
            history[i] = p;
            if (j == 5) {
                print("{d:<10} {d} {any}\n", .{ n, p, delta });
            }
            if (i > 3) {
                const p_old = map.get(delta);
                if (p_old == null or p_old.? < p) {
                    try map.put(delta, Location{ .seller = j, .time = i, .price = p });
                }
                if (std.mem.eql(i64, &delta, &key)) {
                    if (p > price) {
                        price = p;
                    }
                }
            }
        }
        try histories.append(history);
        sum += price;
        try list.append(map);
        // break;
    }

    const best = try getBestPrice(list, alloc);
    // print("sum: {d}\n", .{sum});

    // const key = KeyType{ 0, 2, 0, 0 };
    // const key = KeyType{ -2, 1, -1, 3 };
    // var sum: i64 = 0;
    // for (list.items, 0..) |map, i| {
    //     const val = map.get(key);
    //     if (val != null) {
    //         print("{d}: {d}\n", .{ i, val.? });
    //         sum += val.?;
    //     }
    // }
    // print("sum: {d}\n", .{sum});

    // print("{any}\n", .{list});
    // print("{any}\n", .{list.items[0]});
    //
    // var iter = list.items[0].iterator();
    // while (iter.next()) |kv| {
    //     print("{any}: {d}\n", .{ kv.key_ptr.*, kv.value_ptr.* });
    // }

    return best.price;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readFile("day22.txt", alloc);

    print("{d}\n", .{try run(input, alloc)});
    // print("{d}\n", .{try run2(input, alloc)});
}

test "day22" {
    try testing.expectEqual(37327623, try run(test_input, testing.allocator));
    // try testing.expectEqual(23, try run2(test_input2, testing.allocator));
}
