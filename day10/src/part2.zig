const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/10#part2

fn count(iter: anytype) usize {
    var n: usize = 0;
    while (iter.next()) |_| {
        n += 1;
    }
    iter.reset();
    return n;
}

const Dir = enum {
    N,
    E,
    S,
    W,
    None,

    fn fromOffset(x: isize, y: isize) Dir {
        return switch (x) {
            -1 => Dir.W,
            1 => Dir.E,
            0 => switch (y) {
                1 => Dir.S,
                -1 => Dir.N,
                else => unreachable,
            },
            else => unreachable,
        };
    }
};

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

const DirSet = std.EnumSet(Dir);
fn getDirs(c: u8) DirSet {
    var set = switch (c) {
        '|' => DirSet.initMany(&[_]Dir{ Dir.N, Dir.S }),
        '-' => DirSet.initMany(&[_]Dir{ Dir.W, Dir.E }),
        'L' => DirSet.initMany(&[_]Dir{ Dir.N, Dir.E }),
        'J' => DirSet.initMany(&[_]Dir{ Dir.N, Dir.W }),
        '7' => DirSet.initMany(&[_]Dir{ Dir.W, Dir.S }),
        'F' => DirSet.initMany(&[_]Dir{ Dir.S, Dir.E }),
        'S' => DirSet.initMany(&[_]Dir{ Dir.N, Dir.E, Dir.S, Dir.W }),
        '.' => DirSet.initMany(&[_]Dir{Dir.None}),
        else => unreachable,
    };
    return set;
}

const Tile = struct {
    char: u8,
    dirs: DirSet,
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
            .N => self.dirs.contains(Dir.S),
            .S => self.dirs.contains(Dir.N),
            .E => self.dirs.contains(Dir.W),
            .W => self.dirs.contains(Dir.E),
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
        var iter = currTile.dirs.iterator();
        while (iter.next()) |dir| {
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
    print("   Part 2\n", .{});
    print("************\n", .{});

    var lines = mem.tokenizeScalar(u8, input, '\n');
    const nLines = count(&lines);
    const rowLen = mem.indexOf(u8, input, "\n").?;
    print("# Lines: {d}\n", .{nLines});
    print("Row length: {d}\n", .{rowLen});
    var maze = try Maze.init(input, rowLen, nLines, gpa);
    defer maze.deinit();

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
    print("Start pos: {d}, {d}\n", .{ startPos.x, startPos.y });
    var startDirs = DirSet.initEmpty();
    for ([_]isize{ -1, 1 }) |xOff| {
        const x: isize = @intCast(startPos.x);
        if (x + xOff < 0 or x + xOff >= maze.w) continue;
        nextPos = Pos{
            .x = @intCast(x + xOff),
            .y = startPos.y,
        };
        nextTile = maze.get(nextPos);
        if (nextTile.seen and nextTile.connectsTo(Dir.fromOffset(xOff, 0))) {
            print("{c}\n", .{nextTile.char});
            startDirs.insert(Dir.fromOffset(xOff, 0));
        }
    }
    for ([_]isize{ -1, 1 }) |yOff| {
        const y: isize = @intCast(startPos.y);
        if (y + yOff < 0 or y + yOff >= maze.h) continue;
        nextPos = Pos{
            .x = startPos.x,
            .y = @intCast(y + yOff),
        };
        nextTile = maze.get(nextPos);
        if (nextTile.seen and nextTile.connectsTo(Dir.fromOffset(0, yOff))) {
            print("{c}\n", .{nextTile.char});
            startDirs.insert(Dir.fromOffset(0, yOff));
        }
    }
    print("Start dirs:\n", .{});
    var iter = startDirs.iterator();
    while (iter.next()) |dir| {
        print("{}\n", .{dir});
    }
    var startChar: u8 = undefined;
    for ("|-LJ7F") |c| {
        if (startDirs.eql(getDirs(c))) {
            startChar = c;
            break;
        }
    }
    print("Start char: '{c}'\n", .{startChar});

    var totalEnclosed: usize = 0;
    for (0..maze.h) |y| {
        var within: bool = false;
        var up: bool = false;
        var riding: bool = false;
        for (0..maze.w) |x| {
            var t = maze.get(.{ .x = x, .y = y });
            if (t.seen) {
                const c = if (t.char == 'S') startChar else t.char;
                print("{c}", .{c});
                switch (c) {
                    '|' => {
                        assert(!riding);
                        within = !within;
                    },
                    '-' => {
                        assert(riding);
                    },
                    'L', 'F' => {
                        assert(!riding);
                        riding = true;
                        up = (t.char == 'L');
                    },
                    '7', 'J' => {
                        assert(riding);
                        riding = false;
                        if (up and t.char == '7') {
                            within = !within;
                        }
                        if (!up and t.char == 'J') {
                            within = !within;
                        }
                    },
                    else => {
                        print("\n'{c}' @ {d},{d}\n", .{ c, x, y });
                        assert(false);
                    },
                }
            } else {
                if (within) {
                    print("#", .{});
                } else {
                    print(".", .{});
                }
                totalEnclosed += @intFromBool(within);
            }
        }
        print("\n", .{});
    }
    print("Total enclosed: {d}\n", .{totalEnclosed});
}
