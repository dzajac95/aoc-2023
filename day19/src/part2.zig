const std = @import("std");
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;
const fs = std.fs;
const file = std.fs.File;

const print = std.debug.print;
const assert = std.debug.assert;

// https://adventofcode.com/2023/day/19#part2

var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpaObj.allocator();

fn contains(haystack: []const u8, needle: u8) bool {
    for (haystack) |c| {
        if (c == needle)
            return true;
    }
    return false;
}

fn lol() void {
    print("buy more ram lol\n", .{});
    assert(false);
}

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        print("{s}\n", .{line});
    }
}
