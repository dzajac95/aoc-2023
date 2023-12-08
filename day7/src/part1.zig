const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/7

const HandType = enum(u32) {
    highCard,
    onePair,
    threeKind,
    twoPair,
    fullHouse,
    fourKind,
    fiveKind,
};

fn getRank(c: u8) !u32 {
    if (ascii.isDigit(c)) {
        return try fmt.charToDigit(c, 10);
    } else {
        const val: u32 = switch (c) {
            'T' => 10,
            'J' => 11,
            'Q' => 12,
            'K' => 13,
            'A' => 14,
            else => unreachable,
        };
        return val;
    }
}

const Hand = struct {
    text: [5]u8,
    hType: HandType,
    bid: usize,

    pub fn fromLine(line: []const u8) !Hand {
        var split = mem.splitScalar(u8, line, ' ');
        const text = split.next() orelse return error.ParseError;
        const bidStr = split.next() orelse return error.ParseError;
        const bid = try fmt.parseInt(usize, bidStr, 10);
        var h: Hand = undefined;
        for (0..text.len) |i| {
            h.text[i] = text[i];
        }
        h.bid = bid;
        h.hType = HandType.twoPair;
        return h;
    }
};

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    _ = gpa;
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        print("{s}\n", .{line});
        _ = try Hand.fromLine(line);
    }
}
