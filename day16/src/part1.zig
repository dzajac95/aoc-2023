const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/16

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
    seen: []DirSet,
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
        var seen: []DirSet = try gpa.alloc(DirSet, tmp.items.len);
        for (seen) |*set| {
            set.* = DirSet.initEmpty();
        }
        return Self{
            .data = try tmp.toOwnedSlice(),
            .seen = seen,
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

    fn setSeen(self: *Self, x: usize, y: usize, dir: Dir) void {
        self.seen[self.index(x, y)].insert(dir);
    }

    fn isSeen(self: Self, x: usize, y: usize, dir: Dir) bool {
        return self.seen[self.index(x, y)].contains(dir);
    }

    pub fn followBeam(self: *Self, x: usize, y: usize, dir: Dir, depth: usize) void {
        // check for cycle
        if (self.isSeen(x, y, dir)) {
            return;
        }
        self.setSeen(x, y, dir);
        var currX = x;
        var currY = y;
        const noop = switch (dir) {
            .N, .S => ".|",
            .E, .W => ".-",
        };
        // chew through empty space
        while (contains(noop, self.get(currX, currY))) {
            self.setSeen(currX, currY, dir);
            if (!self.move(&currX, &currY, dir))
                return;
        }
        // rotate/split beam based on char & dir
        const c = self.get(currX, currY);
        self.setSeen(currX, currY, dir);
        var newDirCnt: usize = 1;
        var newDirs = [_]Dir{.N} ** 2;
        switch (c) {
            '/' => switch (dir) {
                .N => newDirs[0] = .E,
                .E => newDirs[0] = .N,
                .S => newDirs[0] = .W,
                .W => newDirs[0] = .S,
            },
            '\\' => switch (dir) {
                .N => newDirs[0] = .W,
                .E => newDirs[0] = .S,
                .S => newDirs[0] = .E,
                .W => newDirs[0] = .N,
            },
            '-' => switch (dir) {
                .N, .S => {
                    newDirs[0] = .E;
                    newDirs[1] = .W;
                    newDirCnt = 2;
                },
                else => unreachable,
            },
            '|' => switch (dir) {
                .E, .W => {
                    newDirs[0] = .N;
                    newDirs[1] = .S;
                    newDirCnt = 2;
                },
                else => unreachable,
            },
            else => unreachable,
        }
        // follow beam starting from the next position
        // for loop ensures that splits get followed appropriately
        for (0..newDirCnt) |i| {
            var newX = currX;
            var newY = currY;
            if (self.move(&newX, &newY, newDirs[i])) {
                self.followBeam(newX, newY, newDirs[i], depth + 1);
            }
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

    pub fn showSeen(self: Self) void {
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                if (self.seen[self.index(x, y)].count() > 0) {
                    print("#", .{});
                } else {
                    print(".", .{});
                }
            }
            print("\n", .{});
        }
    }

    pub fn countSeen(self: Self) usize {
        var sum: usize = 0;
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                sum += if (self.seen[self.index(x, y)].count() > 0) 1 else 0;
            }
        }
        return sum;
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
    grid.followBeam(0, 0, .E, 0);
    grid.disp();
    grid.showSeen();
    print("Total coverage: {d}\n", .{grid.countSeen()});
}
