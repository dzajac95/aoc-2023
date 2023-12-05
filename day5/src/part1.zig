const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/4

const MapEntry = struct {
    destStart: usize,
    srcStart: usize,
    range: usize,
};

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    _ = gpa;
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    // Split input into discrete chunks (seeds, seed-to-soil map, etc.)
    var chunks = mem.tokenizeSequence(u8, input, "\n\n");
    // Process seed numbers in the format:
    // seeds: x y z a b c (...)
    const seedsStr = chunks.next().?;
    var seedSplit = mem.splitSequence(u8, seedsStr, ": ");
    _ = seedSplit.first();
    const seedNumStr = seedSplit.next().?;
    var seedNumSplit = mem.tokenizeScalar(u8, seedNumStr, ' ');
    while (seedNumSplit.next()) |numStr| {
        print("{s}\n", .{numStr});
    }
}
