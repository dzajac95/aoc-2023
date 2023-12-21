const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const math = std.math;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/18#part2

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

const U = .{ .x = 0, .y = -1 };
const D = .{ .x = 0, .y = 1 };
const L = .{ .x = -1, .y = 0 };
const R = .{ .x = 1, .y = 0 };

const Point = struct {
    x: isize,
    y: isize,

    const Self = @This();
    pub fn add(self: Self, other: Self) Self {
        return Self{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }
};

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    var digPlan = mem.tokenizeScalar(u8, input, '\n');
    var currPoint: Point = .{
        .x = 0,
        .y = 0,
    };
    var pointsArr = std.ArrayList(Point).init(gpa);
    defer pointsArr.deinit();
    var boundaryNum: isize = 0;
    try pointsArr.append(currPoint);
    while (digPlan.next()) |instr| {
        const startIdx = mem.indexOfScalar(u8, instr, '#').? + 1;
        const endIdx = mem.indexOfScalar(u8, instr, ')').?;
        const len: isize = try fmt.parseInt(isize, instr[startIdx..][0..5], 16);
        const dirC = instr[endIdx - 1];
        print("{d}, {c}\n", .{ len, dirC });
        var dir: Point = switch (dirC) {
            '0' => R,
            '1' => D,
            '2' => L,
            '3' => U,
            else => unreachable,
        };
        const nextPoint: Point = .{
            .x = currPoint.x + dir.x * len,
            .y = currPoint.y + dir.y * len,
        };
        try pointsArr.append(nextPoint);
        boundaryNum += len;
        currPoint = nextPoint;
    }
    const points = try pointsArr.toOwnedSlice();
    print("Points:\n", .{});
    var area: isize = 0;
    for (0..points.len) |i| {
        area += points[i].x * (points[(i + 1) % points.len].y - points[(i + points.len - 1) % points.len].y);
    }
    area = @divFloor(area, 2);
    area = try math.absInt(area);
    const interiorArea = area - @divFloor(boundaryNum, 2) + 1;
    print("Answer: {d}\n", .{interiorArea + boundaryNum});
}
