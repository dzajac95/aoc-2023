const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/13

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
}

const Grid = struct {
    data: []const u8,
    w: usize,
    h: usize,

    const Self = @This();
    pub fn fromChunk(input: []const u8) Self {
        const w = mem.indexOfScalar(u8, input, '\n') orelse unreachable;
        var iter = mem.tokenizeScalar(u8, input, '\n');
        var numRows: usize = 0;
        while (iter.next()) |_| {
            numRows += 1;
        }
        return Self{
            .data = input,
            .w = w,
            .h = numRows,
        };
    }

    pub fn getIndex(self: Self, x: usize, y: usize) usize {
        return y * self.w + y + x;
    }

    pub fn get(self: Self, x: usize, y: usize) u8 {
        return self.data[self.getIndex(x, y)];
    }

    pub fn mirrorV(self: Self, col: usize) bool {
        // iterate over rows, checking if each row is mirrored over lcol
        var stack = std.ArrayList(u8).init(gpa);
        defer stack.deinit();
        var mirror: bool = undefined;
        for (0..self.h) |y| {
            const start = self.getIndex(0, y);
            const end = self.getIndex(col, y);
            stack.appendSlice(self.data[start..end]) catch lol();
            var rIdx = col;
            mirror = true;
            while (stack.popOrNull()) |c| {
                if (rIdx >= self.w) {
                    break;
                }
                if (c != self.get(rIdx, y)) {
                    mirror = false;
                }
                rIdx += 1;
            }
            stack.clearAndFree();
            if (!mirror) break;
        }
        return mirror;
    }

    pub fn getRow(self: Self, row: usize) []const u8 {
        return self.data[self.getIndex(0, row)..self.getIndex(self.w - 1, row)];
    }

    pub fn mirrorH(self: Self, row: usize) bool {
        var rowIdxStack = std.ArrayList(usize).init(gpa);
        defer rowIdxStack.deinit();
        var mirror: bool = undefined;
        for (0..row) |i| {
            rowIdxStack.append(i) catch lol();
        }
        var rIdx = row;
        while (rowIdxStack.popOrNull()) |i| {
            if (rIdx >= self.h) {
                break;
            }
            // check if rows are equal
            mirror = mem.eql(u8, self.getRow(i), self.getRow(rIdx));
            if (!mirror) break;
            rIdx += 1;
        }
        rowIdxStack.clearAndFree();
        return mirror;
    }
};

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var chunks = mem.tokenizeSequence(u8, input, "\n\n");

    var sum: usize = 0;
    // iterate over chunks
    while (chunks.next()) |chunk| outer: {
        const grid = Grid.fromChunk(chunk);
        for (0..grid.h) |y| {
            for (0..grid.w) |x| {
                print("{c}", .{grid.get(x, y)});
            }
            print("\n", .{});
        }
        // check for vertical mirroring
        for (1..grid.w) |col| {
            if (grid.mirrorV(col)) {
                print("Chunk has vertical mirror at col {d}!\n", .{col});
                sum += col;
                break :outer;
            }
        }
        // check for horizontal mirroring
        for (1..grid.h) |row| {
            if (grid.mirrorH(row)) {
                print("Chunk has horizontal mirror at row {d}!\n", .{row});
                sum += row * 100;
                break :outer;
            }
        }
    }
    print("Total: {d}\n", .{sum});
}
