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
            'J' => 1,
            'T' => 10,
            'Q' => 11,
            'K' => 12,
            'A' => 13,
            else => unreachable,
        };
        return val;
    }
}

fn getIndex(c: u8) u32 {
    return getRank(c) - 1;
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
            const idx = getIndex(c);
            cardCounts[idx] += 1;
        }
        const numJokers = cardCounts[getIndex('J')];
        var uniqueCards: u32 = 0;
        var maxCardCount: u32 = 0;
        // print("{s}\n", .{text});
        for (cardCounts, 0..) |count, i| {
            // Don't count jokers as unique
            if (i != getIndex('J')) {
                uniqueCards += @intFromBool(count > 0);
            }
            if (count > maxCardCount) maxCardCount = count;
        }
        maxCardCount += numJokers;
        // print("Unique cards: {d}\n", .{uniqueCards});
        h.hType = switch (uniqueCards) {
            0 => HandType.fiveKind, // All jokers
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
        // If type is the same, compare individual card rank
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
    print("   Part 2\n", .{});
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
