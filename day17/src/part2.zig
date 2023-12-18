const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/17#part2

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

const Dir = enum { N, E, S, W };
const DirSet = std.EnumSet(Dir);

const Grid = struct {
    data: []u8,
    w: usize,
    h: usize,

    const Self = @This();
    pub fn fromInput(input: []const u8) !Self {
        const w = mem.indexOfScalar(u8, input, '\n') orelse unreachable;
        var lines = mem.tokenizeScalar(u8, input, '\n');
        var numRows: usize = 0;
        var tmp = std.ArrayList(u8).init(gpa);
        defer tmp.deinit();

        while (lines.next()) |line| {
            numRows += 1;
            try tmp.appendSlice(line);
        }
        return Self{
            .data = try tmp.toOwnedSlice(),
            .w = w,
            .h = numRows,
        };
    }

    pub fn deinit(self: Self) void {
        gpa.free(self.data);
        gpa.free(self.seen);
    }

    pub fn index(self: Self, x: usize, y: usize) usize {
        return y * self.w + x;
    }

    pub fn get(self: Self, x: usize, y: usize) u8 {
        return self.data[self.index(x, y)];
    }

    pub fn disp(self: Self) void {
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                print("{c}", .{self.get(x, y)});
            }
            print("\n", .{});
        }
    }

    fn move(self: Self, x: *usize, y: *usize, dir: Dir) bool {
        switch (dir) {
            .N => {
                if (y.* < 1) return false;
                y.* -= 1;
            },
            .E => {
                if (x.* >= self.w - 1) return false;
                x.* += 1;
            },
            .S => {
                if (y.* >= self.h - 1) return false;
                y.* += 1;
            },
            .W => {
                if (x.* < 1) return false;
                x.* -= 1;
            },
        }
        return true;
    }
};

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var grid = try Grid.fromInput(input);
    defer grid.deinit();
    grid.disp();
}
