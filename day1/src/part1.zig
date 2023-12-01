const std = @import("std");
const print = std.debug.print;

// https://adventofcode.com/2023/day/1#part1

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var first: usize = 0;
    var foundFirst = false;
    var last: usize = 0;
    var sum: usize = 0;
    var line_begin: usize = 0;
    var numStr: [2]u8 = undefined;
    var num: usize = 0;
    for (input, 0..input.len) |c, i| {
        if (std.ascii.isDigit(c)) {
            if (!foundFirst) {
                first = i;
                foundFirst = true;
            }
            last = i;
        }
        if (c == '\n' or i == input.len - 1) {
            numStr[0] = input[first];
            numStr[1] = input[last];
            num = try std.fmt.parseInt(usize, &numStr, 10);
            sum += num;
            foundFirst = false;
            line_begin = i + 1;
        }
    }
    print("Final sum: {d}\n", .{sum});
}
