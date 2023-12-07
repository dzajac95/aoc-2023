const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/6

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});

    var lines = mem.tokenizeScalar(u8, input, '\n');
    var times = std.ArrayList(usize).init(gpa);
    var distRecords = std.ArrayList(usize).init(gpa);

    var line = lines.next().?;
    var split = mem.splitScalar(u8, line, ':');
    _ = split.next();
    var valueStr = split.next().?;
    var values = mem.tokenizeScalar(u8, valueStr, ' ');
    while (values.next()) |value| {
        const valueNum = try fmt.parseInt(usize, value, 10);
        try times.append(valueNum);
    }
    line = lines.next().?;
    split = mem.splitScalar(u8, line, ':');
    _ = split.next();
    valueStr = split.next().?;
    values = mem.tokenizeScalar(u8, valueStr, ' ');
    while (values.next()) |value| {
        const valueNum = try fmt.parseInt(usize, value, 10);
        try distRecords.append(valueNum);
    }

    var answer: usize = 1;
    var d: f32 = 0;
    var T: f32 = 0;
    var d1: f32 = 0;
    var d2: f32 = 0;
    var waysToBeat: usize = 0;
    for (times.items, distRecords.items) |time, record| {
        T = @floatFromInt(time);
        d = @floatFromInt(record);
        print("{d}, {d}\n", .{ time, record });
        d1 = -1 * T + @sqrt(T * T - 4 * d) / -2;
        d2 = -1 * T - @sqrt(T * T - 4 * d) / -2;
        waysToBeat = @intFromFloat(@ceil(@fabs(d1 - d2)));
        answer *= waysToBeat;
    }
    print("Answer: {d}\n", .{answer});
}
