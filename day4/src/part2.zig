const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/4#part2

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();

    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});

    var winningNumbers = std.ArrayList(u32).init(gpa);
    var candidateNumbers = std.ArrayList(u32).init(gpa);

    var lines = mem.tokenizeScalar(u8, input, '\n');
    var uniqueCards: usize = 0;
    while (lines.next()) |_| {
        uniqueCards += 1;
    }
    lines.reset();
    var cardTotals: []u32 = try gpa.alloc(u32, uniqueCards);
    @memset(cardTotals, 1);
    while (lines.next()) |line| {
        var split1 = mem.splitSequence(u8, line, ": ");
        // Parse card ID
        const cardStr = split1.next().?;
        var cardSplit = mem.tokenizeScalar(u8, cardStr, ' ');
        _ = cardSplit.next(); // Skip 'Card'
        var idStr = cardSplit.next().?;
        const cardId = try fmt.parseInt(u32, idStr, 10);

        // Split right side into winning numbers and candidate numbers
        const cards = split1.next().?;
        var split2 = mem.splitScalar(u8, cards, '|');
        const winningNumbersStr = split2.next().?;
        const candidateNumbersStr = split2.next().?;

        // Parse out winning numbers
        var nums = mem.tokenizeScalar(u8, winningNumbersStr, ' ');
        while (nums.next()) |numStr| {
            const num = try fmt.parseInt(u32, numStr, 10);
            try winningNumbers.append(num);
        }

        // Parse out candidate numbers
        nums = mem.tokenizeScalar(u8, candidateNumbersStr, ' ');
        while (nums.next()) |numStr| {
            const num = try fmt.parseInt(u32, numStr, 10);
            try candidateNumbers.append(num);
        }

        // Count up matches
        var matches: u32 = 0;
        for (candidateNumbers.items) |candidateNum| {
            for (winningNumbers.items) |winningNum| {
                if (candidateNum == winningNum) {
                    matches += 1;
                }
            }
        }
        // Iterate over N matches, adding copies of downstream cards as needed
        for (cardId..cardId + matches) |i| {
            cardTotals[i] += cardTotals[cardId - 1];
        }
        winningNumbers.clearAndFree();
        candidateNumbers.clearAndFree();
    }
    print("Card totals: ", .{});
    var totalCards: usize = 0;
    for (cardTotals, 0..) |cardTotal, i| {
        print("Card {d}: {d}, ", .{ i + 1, cardTotal });
        totalCards += cardTotal;
    }
    print("\nAnswer: {d}\n", .{totalCards});
}
