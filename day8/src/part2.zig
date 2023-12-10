const std = @import("std");
const print = std.debug.print;
const mem = std.mem;

// https://adventofcode.com/2023/day/8#part2

const Node = struct {
    left: [3]u8,
    right: [3]u8,

    pub fn fromText(input: []const u8) !Node {
        var n: Node = undefined;
        const text = mem.trim(u8, input, "()");
        var split = mem.splitSequence(u8, text, ", ");
        const lTxt = split.next() orelse return error.ParseError;
        const rTxt = split.next() orelse return error.ParseError;
        @memcpy(&n.left, lTxt);
        @memcpy(&n.right, rTxt);
        return n;
    }
};

fn getCycleLength(start: [3]u8, map: std.AutoHashMap([3]u8, Node), instructions: []const u8) usize {
    var count: usize = 0;
    var i: usize = 0;
    var key = start;
    while (key[2] != 'Z') {
        var n = map.get(key).?;
        const instr = instructions[i];
        key = switch (instr) {
            'L' => n.left,
            'R' => n.right,
            else => unreachable,
        };
        i = (i + 1) % instructions.len;
        count += 1;
    }
    return count;
}

fn lcm(xs: []const usize) usize {
    var ans: usize = 1;
    for (xs) |x| {
        ans = ans * x / std.math.gcd(ans, x);
    }
    return ans;
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});

    var nodeMap = std.AutoHashMap([3]u8, Node).init(gpa);
    defer nodeMap.deinit();

    var keysArr = std.ArrayList([3]u8).init(gpa);
    var lines = mem.tokenizeScalar(u8, input, '\n');
    const instructions = lines.next().?;

    var key: [3]u8 = undefined;
    var n: Node = undefined;
    while (lines.next()) |line| {
        var split = mem.splitSequence(u8, line, " = ");
        const keyStr = split.next().?;
        const nodeStr = split.next().?;
        @memcpy(&key, keyStr);
        if (key[2] == 'A') {
            try keysArr.append(key);
        }
        n = try Node.fromText(nodeStr);
        try nodeMap.put(key, n);
    }
    var keys = try keysArr.toOwnedSlice();
    keysArr.deinit();

    var cycles = std.ArrayList(usize).init(gpa);
    for (keys) |k| {
        const cycleLen = getCycleLength(k, nodeMap, instructions);
        print("{s} cycle length: {d}\n", .{ k, cycleLen });
        try cycles.append(cycleLen);
    }
    const ans = lcm(cycles.items);
    print("Answer: {d}\n", .{ans});
}
