const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/4

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var answer: usize = 0;
    var winningNumbers = std.ArrayList(u32).init(gpa);
    var candidateNumbers = std.ArrayList(u32).init(gpa);
    while (lines.next()) |line| {
        var split1 = mem.splitSequence(u8, line, ": ");
        _ = split1.next().?;
        const cards = split1.next().?;
        var split2 = mem.splitScalar(u8, cards, '|');
        const winningNumbersStr = split2.next().?;
        const candidateNumbersStr = split2.next().?;

        var nums = mem.tokenizeScalar(u8, winningNumbersStr, ' ');
        while (nums.next()) |numStr| {
            const num = try fmt.parseInt(u32, numStr, 10);
            try winningNumbers.append(num);
        }

        nums = mem.tokenizeScalar(u8, candidateNumbersStr, ' ');
        while (nums.next()) |numStr| {
            const num = try fmt.parseInt(u32, numStr, 10);
            try candidateNumbers.append(num);
        }

        var points: u32 = 0;
        for (candidateNumbers.items) |candidateNum| {
            for (winningNumbers.items) |winningNum| {
                if (candidateNum == winningNum) {
                    if (points == 0) {
                        points += 1;
                    } else {
                        points *= 2;
                    }
                }
            }
        }
        answer += points;
        winningNumbers.clearAndFree();
        candidateNumbers.clearAndFree();
    }
    print("Answer: {d}\n", .{answer});
}
