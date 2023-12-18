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
    }

    pub fn index(self: Self, x: usize, y: usize) usize {
        return y * self.w + x;
    }

    pub fn get(self: Self, x: usize, y: usize) u8 {
        return self.data[self.index(x, y)];
    }

    pub fn set(self: *Self, x: usize, y: usize, c: u8) void {
        self.data[self.index(x, y)] = c;
    }

    pub fn swap(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize) void {
        const tmp = self.get(x2, y2);
        self.set(x2, y2, self.get(x1, y1));
        self.set(x1, y1, tmp);
    }

    pub fn roll(self: *Self, x: usize, y: usize) void {
        std.debug.assert(self.get(x, y) == 'O');
        var currY: isize = @as(isize, @intCast(y)) - 1;
        while (currY >= 0 and self.get(x, @intCast(currY)) == '.') {
            self.swap(x, @intCast(currY + 1), x, @intCast(currY));
            currY -= 1;
        }
    }

    pub fn disp(self: Self) void {
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                print("{c}", .{self.get(x, y)});
            }
            print("\n", .{});
        }
    }
};

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var grid = try Grid.fromInput(input);
    defer grid.deinit();
    for (0..grid.h) |y| {
        for (0..grid.w) |x| {
            if (grid.get(x, y) == 'O') {
                grid.roll(x, y);
            }
        }
    }
    var sum: usize = 0;
    for (0..grid.h) |y| {
        const value = grid.h - y;
        var numRollers: usize = 0;
        for (0..grid.w) |x| {
            numRollers += if (grid.get(x, y) == 'O') 1 else 0;
        }
        sum += numRollers * value;
    }
    grid.disp();
    print("Answer: {d}\n", .{sum});
}
