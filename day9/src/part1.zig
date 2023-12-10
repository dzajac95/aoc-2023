const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/9

fn getNext(sequence: []const usize, alloc: mem.Allocator) usize {
    var nextSeq: []usize = alloc.alloc(sequence.len - 1);
    defer alloc.free(nextSeq);
    var allZero: bool = true;
    var prev = sequence[0];
    for (1..sequence.len) |i| {
        const diff = sequence[i] - prev;
        nextSeq[i - 1] = diff;
        allZero = allZero and (diff == 0);
    }
    if (allZero) {
        return 0;
    } else {
        return getNext(nextSeq, alloc);
    }
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var values = std.ArrayList(usize).init(gpa);
    while (lines.next()) |line| {
        var vals = 
        print("{s}\n", .{line});
    }
}
