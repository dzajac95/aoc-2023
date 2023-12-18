const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/14#part2

var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpaObj.allocator();

fn contains(haystack: []const u8, needle: u8) bool {
    for (haystack) |c| {
        if (c == needle)
            return true;
    }
    return false;
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

    pub fn clone(self: Self) !Self {
        var newGrid = Self{
            .data = try gpa.alloc(u8, self.w * self.h),
            .w = self.w,
            .h = self.h,
        };
        @memcpy(newGrid.data, self.data);
        return newGrid;
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

    pub fn tiltNorth(self: *Self) void {
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                if (self.get(x, y) == 'O') {
                    var currY: isize = @as(isize, @intCast(y)) - 1;
                    while (currY >= 0 and self.get(x, @intCast(currY)) == '.') {
                        self.swap(x, @intCast(currY + 1), x, @intCast(currY));
                        currY -= 1;
                    }
                }
            }
        }
    }

    pub fn tiltEast(self: *Self) void {
        var x: isize = @intCast(self.w - 1);
        while (x >= 0) {
            for (0..self.h) |y| {
                if (self.get(@intCast(x), y) == 'O') {
                    var currX: usize = @intCast(x + 1);
                    while (currX < self.w and self.get(currX, y) == '.') {
                        self.swap(currX - 1, y, currX, y);
                        currX += 1;
                    }
                }
            }
            x -= 1;
        }
    }

    pub fn tiltSouth(self: *Self) void {
        var y: isize = @intCast(self.h - 1);
        while (y >= 0) {
            for (0..self.w) |x| {
                if (self.get(x, @intCast(y)) == 'O') {
                    var currY: usize = @intCast(y + 1);
                    while (currY < self.h and self.get(x, currY) == '.') {
                        self.swap(x, currY - 1, x, currY);
                        currY += 1;
                    }
                }
            }
            y -= 1;
        }
    }

    pub fn tiltWest(self: *Self) void {
        for (0..self.w) |x| {
            for (0..self.h) |y| {
                if (self.get(x, y) == 'O') {
                    var currX: isize = @as(isize, @intCast(x)) - 1;
                    while (currX >= 0 and self.get(@intCast(currX), y) == '.') {
                        self.swap(@intCast(currX + 1), y, @intCast(currX), y);
                        currX -= 1;
                    }
                }
            }
        }
    }

    pub fn cycle(self: *Self) void {
        self.tiltNorth();
        self.tiltWest();
        self.tiltSouth();
        self.tiltEast();
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

fn calculateLoad(grid: Grid) usize {
    var sum: usize = 0;
    for (0..grid.h) |y| {
        const value = grid.h - y;
        var numRollers: usize = 0;
        for (0..grid.w) |x| {
            numRollers += if (grid.get(x, y) == 'O') 1 else 0;
        }
        sum += numRollers * value;
    }
    return sum;
}

const pattern = [_]usize{
    95270,
    95267,
    95255,
    95254,
    95251,
    95269,
    95252,
    95253,
    95264,
    95262,
    95265,
    95267,
    95273,
    95274,
};

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var grid = try Grid.fromInput(input);
    defer grid.deinit();
    print("Original:\n\n", .{});
    grid.disp();
    const sampleNum = 1000;
    var loadSample = std.ArrayList(usize).init(gpa);
    for (0..sampleNum) |_| {
        grid.cycle();
        const load = calculateLoad(grid);
        try loadSample.append(load);
    }
    const patternIdx = mem.indexOf(usize, loadSample.items, &pattern).?;
    const cyclesRemaining = 1_000_000_000 - patternIdx - 1;
    const rem = cyclesRemaining % pattern.len;
    print("Answer: {d}\n", .{pattern[rem]});
}
