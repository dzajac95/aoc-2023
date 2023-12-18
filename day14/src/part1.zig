const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/14

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
}

const Grid = struct {
    data: []const u8,
    w: usize,
    h: usize,

    const Self = @This();
    pub fn fromChunk(input: []const u8) Self {
        const w = mem.indexOfScalar(u8, input, '\n') orelse unreachable;
        var iter = mem.tokenizeScalar(u8, input, '\n');
        var numRows: usize = 0;
        while (iter.next()) |_| {
            numRows += 1;
        }
        return Self{
            .data = input,
            .w = w,
            .h = numRows,
        };
    }

    pub fn getIndex(self: Self, x: usize, y: usize) usize {
        return y * self.w + y + x;
    }

    pub fn get(self: Self, x: usize, y: usize) u8 {
        return self.data[self.getIndex(x, y)];
    }
};

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        print("{s}\n", .{line});
    }
}
