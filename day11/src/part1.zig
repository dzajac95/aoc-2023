const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/11

const Point = struct {
    const Self = @This();
    x: usize,
    y: usize,

    pub fn eql(self: Self, other: Self) bool {
        return self.x == other.x and self.y == other.y;
    }
};

fn contains(haystack: []const Point, needle: Point) bool {
    for (haystack) |p| {
        if (p.x == needle.x and p.y == needle.y) return true;
    }
    return false;
}

fn distance(a: Point, b: Point) usize {
    return (@max(a.x, b.x) - @min(a.x, b.x)) + (@max(a.y, b.y) - @min(a.y, b.y));
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    const rowLen = mem.indexOf(u8, input, "\n").?;
    print("Row len: {d}\n", .{rowLen});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var numRows: usize = 0;
    while (lines.next()) |_| {
        numRows += 1;
    }
    var galaxies = std.ArrayList(Point).init(gpa);
    for (0..numRows) |y| {
        for (0..rowLen) |x| {
            const c = input[y * numRows + y + x];
            if (c == '#') {
                try galaxies.append(Point{ .x = x, .y = y });
            }
        }
    }
    var expanded = try galaxies.clone();
    // iterate over rows, shifting points as needed
    for (0..numRows) |y| {
        var empty = true;
        for (0..rowLen) |x| {
            const c = input[y * numRows + y + x];
            if (c == '#') {
                empty = false;
            }
        }
        if (empty) {
            for (galaxies.items, 0..) |item, i| {
                if (item.y > y) {
                    expanded.items[i].y += 1;
                }
            }
        }
    }
    // iterate over columns, shifting points as needed
    for (0..rowLen) |x| {
        var empty = true;
        for (0..numRows) |y| {
            const c = input[y * numRows + y + x];
            if (c == '#') {
                empty = false;
            }
        }
        if (empty) {
            for (galaxies.items, 0..) |item, i| {
                if (item.x >= x) {
                    expanded.items[i].x += 1;
                }
            }
        }
    }

    // get bounds and print
    var xMax: usize = 0;
    var yMax: usize = 0;
    for (expanded.items) |galaxy| {
        if (galaxy.x > xMax) {
            xMax = galaxy.x;
        }
        if (galaxy.y > yMax) {
            yMax = galaxy.y;
        }
    }
    for (0..yMax + 1) |y| {
        for (0..xMax + 1) |x| {
            const p = Point{ .x = x, .y = y };
            if (contains(expanded.items, p)) {
                print("#", .{});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
    var sum: usize = 0;
    for (0..expanded.items.len) |i| {
        for (i + 1..expanded.items.len) |j| {
            const p1 = expanded.items[i];
            const p2 = expanded.items[j];
            sum += distance(p1, p2);
        }
    }
    print("Final sum: {d}\n", .{sum});
}
