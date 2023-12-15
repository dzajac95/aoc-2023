const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/12#part2

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    _ = gpa;
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    const rowLen = mem.indexOf(u8, input, "\n").?;
    print("Row len: {d}\n", .{rowLen});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var numRows: usize = 0;
    while (lines.next()) |line| {
        numRows += 1;
        print("{s}\n", .{line});
    }
}
