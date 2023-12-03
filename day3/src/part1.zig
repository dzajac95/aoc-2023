const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/3

const Grid = struct {
    data: []const u8,
    w: usize,
    h: usize,

    pub fn init(data: []const u8, w: usize, h: usize) !Grid {
        return Grid{
            .data = data,
            .w = w,
            .h = h,
        };
    }

    pub fn get(self: Grid, x: usize, y: usize) u8 {
        return self.data[y * self.h + y + x];
    }

    pub fn hasSym(self: Grid, x: usize, y: usize) bool {
        var xStart: usize = 0;
        var yStart: usize = 0;
        var xEnd: usize = self.w;
        var yEnd: usize = self.h;
        if (x > 0) {
            xStart = x - 1;
        }
        if (y > 0) {
            yStart = y - 1;
        }
        if (x < xEnd - 2) {
            xEnd = x + 2;
        }
        if (y < yEnd - 2) {
            yEnd = y + 2;
        }
        var symFound = false;
        for (yStart..yEnd) |j| {
            for (xStart..xEnd) |i| {
                const c = self.get(i, j);
                if (c != '.' and !ascii.isDigit(c)) {
                    symFound = true;
                }
            }
        }
        return symFound;
    }
};

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    // Determine grid dimensions
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var h: usize = 0;
    var w: usize = 0;
    while (lines.next()) |line| {
        h += 1;
        w = line.len;
    }
    var grid = try Grid.init(input, w, h);
    print("Grid Dimensions: {d}w x {d}h\n", .{ grid.w, grid.h });

    var numFound: bool = false;
    var symFound: bool = false;
    var currNum = std.ArrayList(u8).init(gpa);
    defer currNum.deinit();

    var answer: usize = 0;
    for (0..grid.h) |y| {
        for (0..grid.w) |x| {
            const c = grid.get(x, y);
            if (ascii.isDigit(c)) {
                numFound = true;
                try currNum.append(c);
                if (grid.hasSym(x, y)) {
                    symFound = true;
                }
            } else {
                if (symFound) {
                    const num = try fmt.parseInt(usize, currNum.items, 10);
                    print("{d} ", .{num});
                    answer += num;
                }
                currNum.clearAndFree();
                numFound = false;
                symFound = false;
            }
        }
        print("\n", .{});
    }

    print("ANSWER: {d}\n", .{answer});
}
