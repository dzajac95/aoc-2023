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

fn countArrangements(str: []const u8, nums: []const u16) !usize {
    var total: usize = 0;
    var anyUnknown: bool = false;

    var totalSpace: usize = 0;
    for (str) |c| {
        if (c != '.') {
            totalSpace += 1;
            anyUnknown = anyUnknown or c == '?';
        }
    }

    // if there are no unknowns, return 1
    if (!anyUnknown or nums.len == 0) {
        return 1;
    }

    var spaceNeeded: usize = 0;
    for (1..nums.len) |i| {
        spaceNeeded += nums[i];
    }

    const num = nums[0];
    var count: usize = 0;
    var idx: usize = 0;
    const maxIdx = str.len - (spaceNeeded + nums.len - 1);
    var validStartIdxs = std.ArrayList(usize).init(gpa);
    defer validStartIdxs.deinit();

    while (totalSpace - count > spaceNeeded and idx < maxIdx - num + 1) {
        const c = str[idx];
        if (c != '.') {
            count += 1;

            // check if this is a valid starting position
            var valid: bool = true;
            for (0..num) |offset| {
                if (str[idx + offset] == '.') {
                    valid = false;
                    break;
                }
            }
            // If not at the end, make sure next c ISN'T a #
            if (idx + num < str.len)
                valid = valid and str[idx + num] != '#';
            // check for # before the start
            if (idx > 1)
                valid = valid and str[idx - 1] != '#';

            if (valid)
                try validStartIdxs.append(idx);
        }
        idx += 1;
    }

    for (validStartIdxs.items) |startIdx| {
        const next = startIdx + num + 1;
        if (next >= str.len) {
            return 1;
        }
        total += try countArrangements(str[next..], nums[1..]);
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
        const count = try countArrangements(left, nums.items);
        print("Count: {d}\n", .{count});
        nums.clearAndFree();
    }
}
