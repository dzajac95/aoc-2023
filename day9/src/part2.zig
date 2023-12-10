const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/9#part2

fn getNext(sequence: []const i64, alloc: mem.Allocator) i64 {
    var nextSeq: []i64 = alloc.alloc(i64, sequence.len - 1) catch unreachable;
    defer alloc.free(nextSeq);
    var allZero: bool = true;
    // for (sequence) |val| {
    //     print("{d} ", .{val});
    // }
    // print("\n", .{});
    var prev = sequence[0];
    for (1..sequence.len) |i| {
        const diff = sequence[i] - prev;
        nextSeq[i - 1] = diff;
        allZero = allZero and (sequence[i] == 0);
        prev = sequence[i];
    }
    if (allZero) {
        return 0;
    } else {
        return sequence[0] - getNext(nextSeq, alloc);
    }
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    var lines = mem.tokenizeScalar(u8, input, '\n');
    var values = std.ArrayList(i64).init(gpa);
    var sum: i64 = 0;
    while (lines.next()) |line| {
        var valsStr = mem.tokenizeScalar(u8, line, ' ');
        while (valsStr.next()) |valStr| {
            var value = try fmt.parseInt(i64, valStr, 10);
            try values.append(value);
        }
        var n = getNext(values.items, gpa);
        for (values.items) |val| {
            print("{d} ", .{val});
        }
        print("-> {d}\n", .{n});
        sum += n;
        values.clearAndFree();
    }
    print("Final answer: {d}\n", .{sum});
}
