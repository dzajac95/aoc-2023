const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/15

var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpaObj.allocator();

fn hash(str: []const u8) usize {
    var h: usize = 0;
    for (str) |c| {
        h = hashUpdate(h, c);
    }
    return h;
}

fn hashUpdate(h: usize, c: u8) usize {
    var tmp = h;
    tmp += c;
    tmp = tmp * 17;
    tmp = tmp % 256;
    return tmp;
}

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    const trimmed = mem.trim(u8, input, "\n");
    var labels = mem.tokenizeScalar(u8, trimmed, ',');
    var sum: usize = 0;
    while (labels.next()) |label| {
        sum += hash(label);
    }
    print("Answer: {d}\n", .{sum});
}
