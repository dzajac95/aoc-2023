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

fn countArrangements(str: []const u8, nums: []const u16) usize {
    // base cases
    if (str.len == 0) {
        return if (nums.len == 0) 1 else 0;
    }
    if (nums.len == 0) {
        return if (contains(str, '#')) 0 else 1;
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
    return total;
}

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var nums = std.ArrayList(u16).init(gpa);
    defer nums.deinit();

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
        print("{s} -", .{left});
        for (nums.items) |n| {
            print(" {d}", .{n});
        }
        print("\n", .{});
        const count = countArrangements(left, nums.items);
        print("Count: {d}\n", .{count});
        sum += count;
        nums.clearAndFree();
    }
    print("Final answer: {d}\n", .{sum});
}
