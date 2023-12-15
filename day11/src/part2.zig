const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const math = std.math;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/11#part2

pub fn makePoint(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        const Self = @This();
        pub fn eql(self: Self, other: Self) bool {
            return self.x == other.x and self.y == other.y;
        }
    };
}
const Point = makePoint(usize);
fn distance(a: Point, b: Point) usize {
    return (@max(a.x, b.x) - @min(a.x, b.x)) + (@max(a.y, b.y) - @min(a.y, b.y));
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 2\n", .{});
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
    const scale: usize = 1_000_000 - 1;
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
                    expanded.items[i].y += scale;
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
                    expanded.items[i].x += scale;
                }
            }
        }
    }

    var sum: usize = 0;
    for (0..expanded.items.len) |i| {
        for (i + 1..expanded.items.len) |j| {
            sum += distance(expanded.items[i], expanded.items[j]);
        }
    }
    print("Total distance: {d}\n", .{sum});
    print("usize max value: {d}\n", .{math.maxInt(usize)});
}
