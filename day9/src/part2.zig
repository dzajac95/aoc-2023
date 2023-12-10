const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/9#part2

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    _ = gpa;
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        print("{s}\n", .{line});
    }
}
