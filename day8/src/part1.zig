const std = @import("std");
const print = std.debug.print;
const mem = std.mem;

// https://adventofcode.com/2023/day/8

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

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var nodeMap = std.AutoHashMap([3]u8, Node).init(gpa);
    defer nodeMap.deinit();
    var lines = mem.tokenizeScalar(u8, input, '\n');
    const instructions = lines.next().?;
    var key: [3]u8 = undefined;
    var n: Node = undefined;
    while (lines.next()) |line| {
        var split = mem.splitSequence(u8, line, " = ");
        const keyStr = split.next().?;
        const nodeStr = split.next().?;
        @memcpy(&key, keyStr);
        n = try Node.fromText(nodeStr);
        try nodeMap.put(key, n);
    }

    var entryIter = nodeMap.iterator();
    while (entryIter.next()) |entry| {
        n = entry.value_ptr.*;
        key = entry.key_ptr.*;
        print("{s} = ({s}, {s})\n", .{ key, n.left, n.right });
    }
    @memcpy(&key, "AAA");
    n = nodeMap.get(key).?;
    var i: usize = 0;
    var numSteps: usize = 0;
    print("{s}", .{key});
    while (!mem.eql(u8, &key, "ZZZ")) {
        var instr = instructions[i];
        key = switch (instr) {
            'L' => n.left,
            'R' => n.right,
            else => unreachable,
        };
        // print("-{c}>{s}", .{ instr, key });
        n = nodeMap.get(key).?;
        i = (i + 1) % instructions.len;
        numSteps += 1;
    }
    print("\n", .{});
    print("Num steps: {d}\n", .{numSteps});
}
