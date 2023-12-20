const std = @import("std");
const queue = @import("queue.zig");
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;
const fs = std.fs;
const file = std.fs.File;

const print = std.debug.print;
const assert = std.debug.assert;

// https://adventofcode.com/2023/day/18

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

const Dir = enum {
    N,
    E,
    S,
    W,
    pub fn fromChar(c: u8) Dir {
        return switch (c) {
            'L' => .W,
            'R' => .E,
            'U' => .N,
            'D' => .S,
            else => unreachable,
        };
    }
};
const DirSet = std.EnumSet(Dir);

const Grid = struct {
    data: []u8,
    w: usize,
    h: usize,

    const Self = @This();
    pub fn fromEdges(edges: []Edge) !Self {
        var xMax: usize = 0;
        var yMax: usize = 0;
        for (edges) |e| {
            if (e.start.x > xMax) {
                xMax = e.start.x;
            }
            if (e.end.x > xMax) {
                xMax = e.end.x;
            }
            if (e.start.y > yMax) {
                yMax = e.start.y;
            }
            if (e.end.y > yMax) {
                yMax = e.end.y;
            }
        }
        xMax += 1;
        yMax += 1;
        var data: []u8 = try gpa.alloc(u8, xMax * yMax);
        for (0..yMax) |y| {
            for (0..xMax) |x| {
                var onEdge = false;
                for (edges) |e| {
                    if (e.contains(x, y)) {
                        onEdge = true;
                        break;
                    }
                }
                if (onEdge) {
                    data[y * xMax + x] = '#';
                } else {
                    data[y * xMax + x] = '.';
                }
            }
        }
        return Self{
            .data = data,
            .w = xMax,
            .h = yMax,
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

    pub fn disp(self: Self, writer: file.Writer) void {
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                writer.print("{c}", .{self.get(x, y)}) catch {};
            }
            writer.print("\n", .{}) catch {};
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

const iPoint = struct {
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

const Point = struct {
    x: usize,
    y: usize,

    const Self = @This();
    pub fn fromiPoint(p: iPoint) Self {
        assert(p.x >= 0);
        assert(p.y >= 0);
        return Self{
            .x = @intCast(p.x),
            .y = @intCast(p.y),
        };
    }
};

const Color = struct {
    r: u8,
    g: u8,
    b: u8,
};

const Edge = struct {
    start: Point,
    end: Point,
    color: Color,

    const Self = @This();

    fn contains(self: Self, x: usize, y: usize) bool {
        return (x >= @min(self.start.x, self.end.x) and
            x <= @max(self.start.x, self.end.x) and
            y >= @min(self.start.y, self.end.y) and
            y <= @max(self.start.y, self.end.y));
    }
};

const iEdge = struct {
    start: iPoint,
    end: iPoint,
    color: Color = .{ .r = 0, .g = 0, .b = 0 },

    const Self = @This();
    fn fromLine(start: iPoint, line: []const u8) !Self {
        var items = mem.tokenizeScalar(u8, line, ' ');
        const dirStr = items.next().?;
        const lenStr = items.next().?;
        const colorStr = items.next().?;
        const len = try fmt.parseInt(isize, lenStr, 10);
        _ = colorStr;
        const dir = Dir.fromChar(dirStr[0]);
        var end = start;
        switch (dir) {
            .N => end.y -= len,
            .S => end.y += len,
            .E => end.x += len,
            .W => end.x -= len,
        }
        return Self{
            .start = start,
            .end = end,
        };
    }
};

fn normalizeEdges(edges: []iEdge) ![]Edge {
    var minX: isize = std.math.maxInt(isize);
    var minY: isize = std.math.maxInt(isize);
    var normEdges = try gpa.alloc(Edge, edges.len);
    for (edges) |e| {
        if (e.start.x < minX) {
            minX = e.start.x;
        }
        if (e.end.x < minX) {
            minX = e.end.x;
        }
        if (e.start.y < minY) {
            minY = e.start.y;
        }
        if (e.end.y < minY) {
            minY = e.end.y;
        }
    }
    const offset = iPoint{
        .x = try math.absInt(minX),
        .y = try math.absInt(minY),
    };
    for (edges, 0..) |e, i| {
        normEdges[i] = Edge{
            .start = Point.fromiPoint(e.start.add(offset)),
            .end = Point.fromiPoint(e.end.add(offset)),
            .color = e.color,
        };
    }
    return normEdges;
}

fn digInterior(grid: *Grid) !void {
    // assume center is within boundaries
    const center = iPoint{
        .x = @divTrunc(@as(isize, @intCast(grid.w)), 2),
        .y = @divTrunc(@as(isize, @intCast(grid.h)), 2),
    };
    // starting at center, flood fill!
    var q = try queue.Queue(iPoint).init(gpa);
    try q.enqueue(center);
    while (q.dequeue()) |p| {
        if (grid.get(@intCast(p.x), @intCast(p.y)) == '#' or
            p.x < 0 or p.y < 0 or p.x >= grid.w or p.y >= grid.h)
            continue;
        grid.set(@intCast(p.x), @intCast(p.y), '#');
        try q.enqueue(.{ .x = p.x + 1, .y = p.y });
        try q.enqueue(.{ .x = p.x - 1, .y = p.y });
        try q.enqueue(.{ .x = p.x, .y = p.y + 1 });
        try q.enqueue(.{ .x = p.x, .y = p.y - 1 });
    }
}

fn dispBoard(edges: []const Edge) void {
    var xMax: usize = 0;
    var yMax: usize = 0;
    for (edges) |e| {
        if (e.start.x > xMax) {
            xMax = e.start.x;
        }
        if (e.end.x > xMax) {
            xMax = e.end.x;
        }
        if (e.start.y > yMax) {
            yMax = e.start.y;
        }
        if (e.end.y > yMax) {
            yMax = e.end.y;
        }
    }
    xMax += 1;
    yMax += 1;
    print("Bounds: {d}, {d}\n", .{ xMax, yMax });
    for (0..yMax) |y| {
        for (0..xMax) |x| {
            var onEdge = false;
            for (edges) |e| {
                if (e.contains(x, y)) {
                    onEdge = true;
                }
            }
            if (onEdge) {
                print("#", .{});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
}

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var digPlan = mem.tokenizeScalar(u8, input, '\n');
    var edges = std.ArrayList(iEdge).init(gpa);
    defer edges.deinit();

    var start = iPoint{ .x = 0, .y = 0 };
    while (digPlan.next()) |instr| {
        const e = try iEdge.fromLine(start, instr);
        try edges.append(e);
        start = e.end;
    }
    var normEdges = try normalizeEdges(edges.items);
    defer gpa.free(normEdges);
    for (normEdges) |e| {
        print("({d},{d}) => ({d},{d})\n", .{ e.start.x, e.start.y, e.end.x, e.end.y });
    }
    var grid = try Grid.fromEdges(normEdges);
    const stdout = std.io.getStdOut().writer();
    const cwd = fs.cwd();
    var out = try cwd.createFile("out.txt", .{});
    defer out.close();
    var outWriter = if (false) stdout else out.writer();
    try digInterior(&grid);
    var sum: usize = 0;
    for (0..grid.h) |y| {
        for (0..grid.w) |x| {
            sum += if (grid.get(x, y) == '#') 1 else 0;
        }
    }
    grid.disp(outWriter);
    print("Answer: {d}\n", .{sum});
}
