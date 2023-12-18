const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/12

var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpaObj.allocator();

fn contains(haystack: []const u8, needle: u8) bool {
    for (haystack) |c| {
        if (c == needle)
            return true;
    }
    return false;
}

const Key = struct {
    str: []const u8,
    nums: []const u16,
};

const Context = struct {
    pub fn hash(ctx: @This(), key: Key) u64 {
        _ = ctx;
        var hasher = std.hash.Wyhash.init(0);
        std.hash.autoHashStrat(&hasher, key, .Deep);
        return hasher.final();
    }
    pub fn eql(ctx: @This(), a: Key, b: Key) bool {
        _ = ctx;
        return mem.eql(u8, a.str, b.str) and mem.eql(u16, a.nums, b.nums);
    }
};

var cache = std.HashMap(Key, usize, Context, 80).init(gpa);
fn countArrangements(str: []const u8, nums: []const u16) usize {
    // base cases
    if (str.len == 0) {
        return if (nums.len == 0) 1 else 0;
    }
    if (nums.len == 0) {
        return if (contains(str, '#')) 0 else 1;
    }
    const key = Key{ .str = str, .nums = nums };
    if (cache.contains(key)) {
        return cache.get(key) orelse unreachable;
    }
    var total: usize = 0;
    if (contains(".?", str[0])) {
        total += countArrangements(str[1..], nums);
    }
    if (contains("#?", str[0])) {
        if (nums[0] <= str.len and !contains(str[0..nums[0]], '.')) {
            if (nums[0] == str.len) {
                total += countArrangements("", nums[1..]);
            } else if (str[nums[0]] != '#') {
                total += countArrangements(str[nums[0] + 1 ..], nums[1..]);
            }
        }
    }
    cache.put(key, total) catch print("but more ram lol\n", .{});
    return total;
}

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var nums = std.ArrayList(u16).init(gpa);
    defer nums.deinit();
    var configuration = std.ArrayList(u8).init(gpa);
    defer configuration.deinit();

    var sum: usize = 0;
    while (lines.next()) |line| {
        var split = mem.tokenizeScalar(u8, line, ' ');
        const left = split.next().?;
        const right = split.next().?;
        split = mem.tokenizeScalar(u8, right, ',');
        while (split.next()) |numStr| {
            const num = try fmt.parseInt(u16, numStr, 10);
            try nums.append(num);
        }

        // 'unfold' config string + numbers
        const numSlice = try nums.toOwnedSlice();
        for (0..5) |i| {
            try configuration.appendSlice(left);
            if (i != 4) {
                try configuration.append('?');
            }
            try nums.appendSlice(numSlice);
        }
        gpa.free(numSlice);

        const count = countArrangements(configuration.items, nums.items);
        sum += count;
        nums.clearAndFree();
        configuration.clearAndFree();
        cache.clearAndFree();
    }
    print("Final answer: {d}\n", .{sum});
}
