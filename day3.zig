const std = @import("std");

const RegexError = error{
    InvalidPattern,
    NoMatch,
};

const test_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
const test_input2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

fn readFile(filename: []const u8) ![]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();
    const text = try file.readToEndAlloc(std.heap.page_allocator, std.math.maxInt(usize));
    return text;
}

fn getMatch(string: [*]const u8, matches: []re.regmatch_t, imatch: usize) RegexError![]const u8 {
    const m = matches[imatch];

    if (m.rm_so == -1) {
        return RegexError.NoMatch;
    }

    const start_offset: usize = @intCast(m.rm_so);
    const end_offset: usize = @intCast(m.rm_eo);
    return string[start_offset..end_offset];
}

const re = @cImport(@cInclude("re.h"));

fn run(input: []const u8) !u32 {
    const regex = re.alloc_regex_t();
    defer re.free_regex_t(regex);

    if (re.regcomp(regex,
        \\mul\(([0-9]{1,3}),([0-9]{1,3})\)
    , re.REG_EXTENDED) != 0) {
        return RegexError.InvalidPattern;
    }

    var result: u32 = 0;
    var row = std.mem.split(u8, input, "\n");
    while (row.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var start: usize = 0;
        while (start < line.len) {
            var matches: [1024]re.regmatch_t = undefined;
            const substr: [*c]const u8 = @ptrCast(line[start..]);

            if (re.regexec(regex, substr, matches.len, &matches, 0) != 0) {
                break;
            }

            const a = try std.fmt.parseInt(u32, try getMatch(substr, &matches, 1), 10);
            const b = try std.fmt.parseInt(u32, try getMatch(substr, &matches, 2), 10);
            start += @as(usize, @intCast(matches[0].rm_eo));
            result += a * b;
        }
    }
    return result;
}

fn run2(input: []const u8) !u32 {
    const regex = re.alloc_regex_t();
    defer re.free_regex_t(regex);

    if (re.regcomp(regex,
        \\mul\(([0-9]{1,3}),([0-9]{1,3})\)|do\(\)|don't\(\)
    , re.REG_EXTENDED) != 0) {
        return RegexError.InvalidPattern;
    }

    var enabled: bool = true;
    var result: u32 = 0;
    var row = std.mem.split(u8, input, "\n");
    while (row.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var start: usize = 0;
        while (start < line.len) {
            var matches: [1024]re.regmatch_t = undefined;
            const substr: [*c]const u8 = @ptrCast(line[start..]);

            if (re.regexec(regex, substr, matches.len, &matches, 0) != 0) {
                break;
            }

            const match = try getMatch(substr, &matches, 0);

            if (std.mem.eql(u8, match, "do()")) {
                enabled = true;
            } else if (std.mem.eql(u8, match, "don't()")) {
                enabled = false;
            } else if (enabled) {
                const a = try std.fmt.parseInt(u32, try getMatch(substr, &matches, 1), 10);
                const b = try std.fmt.parseInt(u32, try getMatch(substr, &matches, 2), 10);
                result += a * b;
            }
            start += @as(usize, @intCast(matches[0].rm_eo));
        }
    }
    return result;
}

pub fn main() !void {
    const text = try readFile("day3.txt");

    const result = try run(text);
    std.debug.print("{d}\n", .{result});

    const result2 = try run2(text);
    std.debug.print("{d}\n", .{result2});
}

test "day3" {
    try std.testing.expectEqual(161, try run(test_input));
    try std.testing.expectEqual(48, try run2(test_input2));
}

// $ zig run day3.zig re.c -I.
