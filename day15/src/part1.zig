const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/15

var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpaObj.allocator();

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    const trimmed = mem.trim(u8, input, "\n");
    var items = mem.tokenizeScalar(u8, trimmed, ',');
    while (items.next()) |item| {
        print("{s}\n", .{item});
    }
}
