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

fn fDistance(p1: Point, p2: Point) f64 {
    const x1: f64 = @floatFromInt(p1.x);
    const y1: f64 = @floatFromInt(p1.y);
    const x2: f64 = @floatFromInt(p2.x);
    const y2: f64 = @floatFromInt(p2.y);
    return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}

const Offset = struct {
    x: i32,
    y: i32,
};

const N = Offset{ .x = 0, .y = -1 };
const E = Offset{ .x = 1, .y = 0 };
const S = Offset{ .x = 0, .y = 1 };
const W = Offset{ .x = -1, .y = 0 };

const DistResult = struct {
    dist: usize,
    trace: []Point,
};

fn distance(p1: Point, p2: Point, alloc: mem.Allocator) !DistResult {
    var currPos: Point = p1;
    var nextPos: Point = undefined;
    var trace = std.ArrayList(Point).init(alloc);
    var steps: usize = 0;
    while (!currPos.eql(p2)) {
        var minDistance: f64 = math.floatMax(f64);
        const x: isize = @intCast(currPos.x);
        const y: isize = @intCast(currPos.y);
        for ([_]Offset{ N, E, S, W }) |off| {
            if (x + off.x < 0 or y + off.y < 0) continue;
            nextPos = Point{
                .x = @intCast(x + off.x),
                .y = @intCast(y + off.y),
            };
            const dist = fDistance(nextPos, p2);
            if (dist < minDistance) {
                minDistance = dist;
                currPos = nextPos;
            }
        }
        try trace.append(currPos);
        steps += 1;
    }
    return DistResult{
        .dist = steps,
        .trace = try trace.toOwnedSlice(),
    };
}

pub fn printPath(p1: Point, p2: Point, trace: []const Point, bounds: Point) void {
    for (0..bounds.y + 1) |y| {
        for (0..bounds.x + 1) |x| {
            const p = Point{ .x = x, .y = y };
            if (p.eql(p1)) {
                print("1", .{});
            } else if (p.eql(p2)) {
                print("2", .{});
            } else if (contains(trace, p)) {
                print("#", .{});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
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
    // const bounds = Point{ .x = xMax, .y = yMax };
    // calculate distance for each pair and get sum
    var sum: usize = 0;
    var res: DistResult = undefined;
    for (0..expanded.items.len) |i| {
        for (i + 1..expanded.items.len) |j| {
            const p1 = expanded.items[i];
            const p2 = expanded.items[j];
            res = try distance(p1, p2, gpa);
            // printPath(p1, p2, res.trace, bounds);
            // print("\n", .{});
            sum += res.dist;
            gpa.free(res.trace);
        }
    }
    print("Final sum: {d}\n", .{sum});
}
