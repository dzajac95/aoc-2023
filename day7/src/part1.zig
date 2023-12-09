const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/7

const HandType = enum {
    highCard,
    onePair,
    twoPair,
    threeKind,
    fullHouse,
    fourKind,
    fiveKind,
};

fn getRank(c: u8) u32 {
    if (ascii.isDigit(c)) {
        return fmt.charToDigit(c, 10) catch unreachable;
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
        // Get the basic info
        const text = split.next() orelse return error.ParseError;
        const bidStr = split.next() orelse return error.ParseError;
        const bid = try fmt.parseInt(usize, bidStr, 10);
        var h: Hand = undefined;
        for (0..text.len) |i| {
            h.text[i] = text[i];
        }
        h.bid = bid;

        // Determine hand type based on # unique and max # of a single card type
        var cardCounts: [13]u32 = undefined;
        @memset(&cardCounts, 0);
        for (text) |c| {
            const idx = getRank(c) - 2;
            cardCounts[idx] += 1;
        }
        var uniqueCards: u32 = 0;
        var maxCardCount: u32 = 0;
        for (cardCounts) |count| {
            uniqueCards += @intFromBool(count > 0);
            if (count > maxCardCount) maxCardCount = count;
        }
        h.hType = switch (uniqueCards) {
            1 => HandType.fiveKind,
            2 => switch (maxCardCount) {
                4 => HandType.fourKind,
                else => HandType.fullHouse,
            },
            3 => switch (maxCardCount) {
                3 => HandType.threeKind,
                else => HandType.twoPair,
            },
            4 => HandType.onePair,
            5 => HandType.highCard,
            else => unreachable,
        };
        return h;
    }
};

fn handLt(_: void, lhs: Hand, rhs: Hand) bool {
    if (lhs.hType == rhs.hType) {
        for (lhs.text, rhs.text) |l, r| {
            if (l == r) {
                continue;
            } else {
                return getRank(l) < getRank(r);
            }
        }
        return false;
    } else {
        return @intFromEnum(lhs.hType) < @intFromEnum(rhs.hType);
    }
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var hands = std.ArrayList(Hand).init(gpa);
    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const hand = try Hand.fromLine(line);
        try hands.append(hand);
    }
    mem.sort(Hand, hands.items, {}, handLt);
    var totalWinnings: usize = 0;
    for (hands.items, 0..) |hand, i| {
        const ranking = i + 1;
        print("{s}, {}, {d}\n", .{ hand.text, hand.hType, ranking });
        totalWinnings += hand.bid * ranking;
    }
    print("Total winnings: {d}\n", .{totalWinnings});
}
