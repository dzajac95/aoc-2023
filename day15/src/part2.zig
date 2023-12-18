const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const fmt = std.fmt;

// https://adventofcode.com/2023/day/15#part2

var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpaObj.allocator();

fn hash(str: []const u8) usize {
    var h: usize = 0;
    for (str) |c| {
        h = hashUpdate(h, c);
    }
    return h;
}

fn hashUpdate(h: usize, c: u8) usize {
    var tmp = h;
    tmp += c;
    tmp = tmp * 17;
    tmp = tmp % 256;
    return tmp;
}

const Lens = struct {
    label: []const u8,
    focalLength: usize,
};

const Box = std.ArrayList(Lens);

fn find(haystack: Box, needle: []const u8) ?usize {
    for (haystack.items, 0..) |box, i| {
        if (mem.eql(u8, box.label, needle)) {
            return i;
        }
    }
    return null;
}

fn lol() void {
    print("buy more ram lol\n", .{});
    assert(false);
}

const HASHMAP = struct {
    boxes: [256]Box = [_]Box{Box.init(gpa)} ** 256,

    const Self = @This();

    pub fn deinit(self: *Self) void {
        for (self.boxes) |box| {
            box.deinit();
        }
    }
    pub fn addLens(self: *Self, instruction: []const u8) void {
        const endIdx = mem.indexOfAny(u8, instruction, "-=") orelse unreachable;
        const lensLabel = instruction[0..endIdx];
        const idx = hash(lensLabel);
        if (mem.indexOfScalar(u8, instruction, '-')) |_| {
            print("Removing '{s}'\n", .{lensLabel});
            // remove
            if (find(self.boxes[idx], lensLabel)) |labelIdx| {
                _ = self.boxes[idx].orderedRemove(labelIdx);
            }
        }
        if (mem.indexOfScalar(u8, instruction, '=')) |_| {
            const focal = fmt.charToDigit(instruction[instruction.len - 1], 10) catch unreachable;
            print("Inserting '{s} {d}'\n", .{ lensLabel, focal });
            // insert
            if (find(self.boxes[idx], lensLabel)) |labelIdx| {
                self.boxes[idx].items[labelIdx].focalLength = focal;
            } else {
                self.boxes[idx].append(Lens{ .label = lensLabel, .focalLength = focal }) catch lol();
            }
        }
    }

    pub fn totalPower(self: Self) usize {
        var sum: usize = 0;
        for (self.boxes, 0..) |box, boxIdx| {
            for (box.items, 0..) |lens, lensIdx| {
                const slot = lensIdx + 1;
                const boxNum = boxIdx + 1;
                sum += boxNum * slot * lens.focalLength;
            }
        }
        return sum;
    }
    pub fn disp(self: Self) void {
        for (self.boxes, 0..) |box, i| {
            if (box.items.len > 0) {
                print("Box {d}:", .{i});
                for (box.items) |lens| {
                    print(" [{s} {d}]", .{ lens.label, lens.focalLength });
                }
                print("\n", .{});
            }
        }
    }
};

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    const trimmed = mem.trim(u8, input, "\n");
    var instructions = mem.tokenizeScalar(u8, trimmed, ',');
    var map: HASHMAP = .{};
    defer map.deinit();
    while (instructions.next()) |instr| {
        map.addLens(instr);
    }
    map.disp();
    print("Answer: {d}\n", .{map.totalPower()});
}
