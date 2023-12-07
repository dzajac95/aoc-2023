const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/6#part2

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});

    var tmpStr = std.ArrayList(u8).init(gpa);
    var lines = mem.splitScalar(u8, input, '\n');

    var line = lines.next().?;
    var split = mem.splitScalar(u8, line, ':');
    _ = split.next();
    var valueStr = split.next().?;
    var digits = mem.tokenizeScalar(u8, valueStr, ' ');
    while (digits.next()) |digitSlice| {
        try tmpStr.appendSlice(digitSlice);
    }
    const T = try fmt.parseFloat(f64, tmpStr.items);
    print("Time: {d}\n", .{T});
    tmpStr.clearAndFree();

    line = lines.next().?;
    split = mem.splitScalar(u8, line, ':');
    _ = split.next();
    valueStr = split.next().?;
    digits = mem.tokenizeScalar(u8, valueStr, ' ');
    while (digits.next()) |digitSlice| {
        try tmpStr.appendSlice(digitSlice);
    }
    const d = try fmt.parseFloat(f64, tmpStr.items);
    print("Distance: {d}\n", .{d});

    var d1 = -1 * T + @sqrt(T * T - 4 * d) / -2;
    var d2 = -1 * T - @sqrt(T * T - 4 * d) / -2;
    const answer: usize = @intFromFloat(@floor(@fabs(d1 - d2)));
    print("Answer: {d}\n", .{answer});
}
