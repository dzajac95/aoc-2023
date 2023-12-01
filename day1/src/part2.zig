const std = @import("std");
const print = std.debug.print;

// https://adventofcode.com/2023/day/1#part2

const digit_words = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    var first: usize = 0;
    var firstNum: usize = 0;
    var foundFirst = false;
    var last: usize = 0;
    var lastNum: usize = 0;
    var sum: usize = 0;
    var numStr: [2]u8 = undefined;
    var num: usize = 0;

    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        // first look for numeric digits
        for (0..line.len) |i| {
            const c = line[i];
            if (std.ascii.isDigit(c)) {
                if (!foundFirst) {
                    first = i;
                    foundFirst = true;
                }
                last = i;
            }
        }
        firstNum = try std.fmt.charToDigit(line[first], 10);
        lastNum = try std.fmt.charToDigit(line[last], 10);

        // now look for words, replacing first/last if necessary
        for (1..digit_words.len) |i| {
            const word = digit_words[i];
            if (std.mem.indexOf(u8, line, word)) |idx| {
                if (idx < first) {
                    first = idx;
                    firstNum = i;
                }
            }
            if (std.mem.lastIndexOf(u8, line, word)) |idx| {
                if (idx > last) {
                    last = idx;
                    lastNum = i;
                }
            }
        }
        numStr[0] = std.fmt.digitToChar(@intCast(firstNum), std.fmt.Case.lower);
        numStr[1] = std.fmt.digitToChar(@intCast(lastNum), std.fmt.Case.lower);
        num = try std.fmt.parseInt(usize, &numStr, 10);
        sum += num;
        foundFirst = false;
    }
    print("Final sum: {d}\n", .{sum});
}
