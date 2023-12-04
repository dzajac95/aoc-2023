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

    pub fn getBounds(self: Grid, x: usize, y: usize) Rect {
        var bounds = Rect{ .x = x, .y = y, .w = 3, .h = 3 };
        if (bounds.x > 0) {
            bounds.x -= 1;
        }
        if (bounds.y > 0) {
            bounds.y -= 1;
        }
        if (bounds.x < self.w - 2) {
            bounds.w = 3;
        } else {
            bounds.w = self.w - bounds.x;
        }
        if (bounds.y < self.h - 2) {
            bounds.h = 3;
        } else {
            bounds.h = self.h - bounds.y;
        }
        return bounds;
    }
};

const Point = struct {
    x: usize,
    y: usize,
};
const PartNumber = struct {
    value: usize,
    pos: Point,
    len: usize,
};

const Rect = struct {
    x: usize,
    y: usize,
    w: usize,
    h: usize,
};

pub fn intersects(bounds: Rect, part: PartNumber) bool {
    // first check y position
    var yInBound = false;
    for (bounds.y..bounds.y + bounds.h) |y| {
        if (y == part.pos.y) {
            yInBound = true;
        }
    }
    if (!yInBound) return false;

    // now x
    var xInBound = false;
    for (part.pos.x..part.pos.x + part.len) |x| {
        if (x >= bounds.x and x < bounds.x + bounds.w) {
            xInBound = true;
        }
    }
    return xInBound and yInBound;
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 2\n", .{});
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

    var currNum = std.ArrayList(u8).init(gpa);
    defer currNum.deinit();
    var partNums = std.ArrayList(PartNumber).init(gpa);
    var numFound = false;
    var startPos = Point{ .x = 0, .y = 0 };
    for (0..grid.h) |y| {
        for (0..grid.w + 1) |x| {
            const c = grid.get(x, y);
            if (ascii.isDigit(c)) {
                try currNum.append(c);
                if (!numFound) {
                    startPos.x = x;
                    startPos.y = y;
                }
                numFound = true;
            } else {
                if (numFound) {
                    const num = try fmt.parseInt(usize, currNum.items, 10);
                    try partNums.append(PartNumber{
                        .pos = startPos,
                        .len = currNum.items.len,
                        .value = num,
                    });
                    currNum.clearAndFree();
                    numFound = false;
                }
            }
        }
    }

    var starCount: usize = 0;
    var answer: usize = 0;
    for (0..grid.h) |y| {
        for (0..grid.w) |x| {
            const c = grid.get(x, y);
            if (c == '*') {
                var neighbors: usize = 0;
                var gearRatio: usize = 1;
                // print("star @ {d},{d}\n", .{ x, y });
                starCount += 1;
                const bounds = grid.getBounds(x, y);
                // print("neighbors: ", .{});
                for (partNums.items) |part| {
                    if (intersects(bounds, part)) {
                        print("{d} ", .{part.value});
                        neighbors += 1;
                        gearRatio *= part.value;
                    }
                }
                if (neighbors == 2) {
                    answer += gearRatio;
                }
                // print("\n", .{});
            }
        }
    }
    print("Answer: {d}\n", .{answer});
}
