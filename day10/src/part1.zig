const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/10

fn count(iter: anytype) usize {
    var n: usize = 0;
    while (iter.next()) |_| {
        n += 1;
    }
    iter.reset();
    return n;
}

fn north(pos: Pos) Pos {
    assert(pos.y >= 1);
    return Pos{
        .x = pos.x,
        .y = pos.y - 1,
    };
}

fn east(pos: Pos) Pos {
    return Pos{
        .x = pos.x + 1,
        .y = pos.y,
    };
}

fn south(pos: Pos) Pos {
    return Pos{
        .x = pos.x,
        .y = pos.y + 1,
    };
}

fn west(pos: Pos) Pos {
    assert(pos.x >= 1);
    return Pos{
        .x = pos.x - 1,
        .y = pos.y,
    };
}

fn has(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |c| {
        if (c == needle) {
            return true;
        }
    }
    return false;
}

const Dir = enum {
    N,
    E,
    S,
    W,
    None,
};

fn getDirs(c: u8) []const Dir {
    return switch (c) {
        '|' => &[_]Dir{ Dir.N, Dir.S },
        '-' => &[_]Dir{ Dir.W, Dir.E },
        'L' => &[_]Dir{ Dir.N, Dir.E },
        'J' => &[_]Dir{ Dir.N, Dir.W },
        '7' => &[_]Dir{ Dir.W, Dir.S },
        'F' => &[_]Dir{ Dir.S, Dir.E },
        'S' => &[_]Dir{ Dir.N, Dir.E, Dir.S, Dir.W },
        '.' => &[_]Dir{Dir.None},
        else => unreachable,
    };
}

const Tile = struct {
    char: u8,
    dirs: []const Dir,
    seen: bool,

    fn create(c: u8) Tile {
        return Tile{
            .char = c,
            .dirs = getDirs(c),
            .seen = false,
        };
    }

    fn connectsTo(self: Tile, dir: Dir) bool {
        return switch (dir) {
            .N => has(Dir, self.dirs, Dir.S),
            .S => has(Dir, self.dirs, Dir.N),
            .E => has(Dir, self.dirs, Dir.W),
            .W => has(Dir, self.dirs, Dir.E),
            .None => unreachable,
        };
    }
};

const Maze = struct {
    tiles: []Tile,
    w: usize,
    h: usize,
    alloc: mem.Allocator,

    pub fn init(data: []const u8, w: usize, h: usize, alloc: mem.Allocator) !Maze {
        var tiles = try alloc.alloc(Tile, w * h);
        for (0..h) |y| {
            for (0..w) |x| {
                const idx = y * h + x;
                tiles[idx] = Tile.create(data[idx + y]);
            }
        }
        return Maze{
            .tiles = tiles,
            .w = w,
            .h = h,
            .alloc = alloc,
        };
    }

    fn index(self: Maze, x: usize, y: usize) usize {
        return y * self.h + x;
    }

    pub fn get(self: Maze, pos: Pos) *Tile {
        return &self.tiles[self.index(pos.x, pos.y)];
    }

    pub fn deinit(self: Maze) void {
        self.alloc.free(self.tiles);
    }

    pub fn getNext(self: Maze, pos: Pos) ?Pos {
        var currTile = self.get(pos);
        currTile.seen = true;

        for (currTile.dirs) |dir| {
            const nextPos = switch (dir) {
                .N => north(pos),
                .E => east(pos),
                .S => south(pos),
                .W => west(pos),
                .None => unreachable,
            };
            const nextTile = self.get(nextPos);
            if (nextTile.connectsTo(dir) and !nextTile.seen) {
                return nextPos;
            }
        }
        return null;
    }
};

const Pos = struct {
    x: usize,
    y: usize,
};

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});

    var lines = mem.tokenizeScalar(u8, input, '\n');
    const nLines = count(&lines);
    const rowLen = mem.indexOf(u8, input, "\n").?;
    print("# Lines: {d}\n", .{nLines});
    print("Row length: {d}\n", .{rowLen});
    var maze = try Maze.init(input, rowLen, nLines, gpa);
    defer maze.deinit();

    for (0..maze.h) |y| {
        for (0..maze.w) |x| {
            const pos = Pos{ .x = x, .y = y };
            print("{c}", .{maze.get(pos).char});
        }
        print("\n", .{});
    }

    const startIdx = mem.indexOf(u8, input, "S").?;
    const startPos = Pos{
        .x = startIdx % (rowLen + 1),
        .y = startIdx / (rowLen + 1),
    };
    var nextPos = maze.getNext(startPos).?;
    var nextTile = maze.get(nextPos);
    var pathLen: usize = 1;
    while (!nextTile.seen) {
        // print("Next tile: {c} @ {d}, {d}\n", .{ nextTile.char, nextPos.x, nextPos.y });
        nextPos = maze.getNext(nextPos) orelse break;
        nextTile = maze.get(nextPos);
        pathLen += 1;
    }
    for (0..maze.h) |y| {
        for (0..maze.w) |x| {
            var t = maze.get(.{ .x = x, .y = y });
            if (t.seen) {
                print("{c}", .{t.char});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
    print("Total steps in loop: {d}\n", .{pathLen});
    print("Steps to farthest point: {d}\n", .{(pathLen + 1) / 2});
}
