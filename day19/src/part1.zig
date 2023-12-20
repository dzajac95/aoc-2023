const std = @import("std");
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;
const fs = std.fs;
const file = std.fs.File;

const print = std.debug.print;
const assert = std.debug.assert;

// https://adventofcode.com/2023/day/19

var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpaObj.allocator();

fn contains(haystack: []const u8, needle: u8) bool {
    for (haystack) |c| {
        if (c == needle)
            return true;
    }
    return false;
}

fn lol() void {
    print("buy more ram lol\n", .{});
    assert(false);
}

const Category = enum { xcool, musical, aero, shiny, none };

const Op = enum {
    lt,
    gt,
    none,
};

const Rule = struct {
    cat: Category = .none,
    op: Op = .none,
    value: usize = 0,
    dest: []const u8 = "",
};

const PartRating = struct {
    x: usize,
    m: usize,
    a: usize,
    s: usize,
};

fn parseWorkflows(map: *std.StringHashMap([]Rule), str: []const u8) !void {
    var lines = mem.tokenizeScalar(u8, str, '\n');
    var wf = std.ArrayList(Rule).init(gpa);
    while (lines.next()) |line| {
        const wfStart = mem.indexOfScalar(u8, line, '{').?;
        const wfEnd = mem.indexOfScalar(u8, line, '}').?;
        const id = line[0..wfStart];
        const wfStr = line[wfStart + 1 .. wfEnd];
        var rulesIter = mem.tokenizeScalar(u8, wfStr, ',');
        while (rulesIter.next()) |ruleStr| {
            var rule: Rule = .{};
            if (mem.indexOfScalar(u8, ruleStr, ':')) |sepIdx| {
                const left = ruleStr[0..sepIdx];
                const right = ruleStr[sepIdx + 1 ..];
                const catC = left[0];
                const opC = left[1];
                const valStr = left[2..];
                rule.cat = switch (catC) {
                    'x' => .xcool,
                    'm' => .musical,
                    'a' => .aero,
                    's' => .shiny,
                    else => unreachable,
                };
                rule.op = switch (opC) {
                    '<' => .lt,
                    '>' => .gt,
                    else => unreachable,
                };
                rule.value = try fmt.parseInt(usize, valStr, 10);
                rule.dest = right;
            } else {
                rule.dest = ruleStr;
            }
            try wf.append(rule);
        }
        const slice = try wf.toOwnedSlice();
        try map.put(id, slice);
        wf.clearAndFree();
    }
}

fn parseParts(list: *std.ArrayList(PartRating), str: []const u8) !void {
    var lines = mem.tokenizeScalar(u8, str, '\n');
    while (lines.next()) |line| {
        const trimmed = mem.trim(u8, line, "{}");
        var ratings = mem.splitScalar(u8, trimmed, ',');

        const xStr = ratings.next().?;
        const mStr = ratings.next().?;
        const aStr = ratings.next().?;
        const sStr = ratings.next().?;

        const x = try fmt.parseInt(usize, xStr[2..], 10);
        const m = try fmt.parseInt(usize, mStr[2..], 10);
        const a = try fmt.parseInt(usize, aStr[2..], 10);
        const s = try fmt.parseInt(usize, sStr[2..], 10);

        try list.append(PartRating{
            .x = x,
            .m = m,
            .a = a,
            .s = s,
        });
    }
}

fn isAccepted(part: PartRating, key: []const u8, map: std.StringHashMap([]Rule)) bool {
    if (map.get(key)) |wf| {
        for (wf) |rule| {
            var match = false;
            switch (rule.cat) {
                .xcool => {
                    match = (rule.op == .lt and part.x < rule.value or
                        rule.op == .gt and part.x > rule.value);
                },
                .musical => {
                    match = (rule.op == .lt and part.m < rule.value or
                        rule.op == .gt and part.m > rule.value);
                },
                .aero => {
                    match = (rule.op == .lt and part.a < rule.value or
                        rule.op == .gt and part.a > rule.value);
                },
                .shiny => {
                    match = (rule.op == .lt and part.s < rule.value or
                        rule.op == .gt and part.s > rule.value);
                },
                .none => {
                    match = true;
                },
            }
            if (match) {
                if (mem.eql(u8, rule.dest, "A")) {
                    return true;
                } else if (mem.eql(u8, rule.dest, "R")) {
                    return false;
                } else {
                    return isAccepted(part, rule.dest, map);
                }
            }
        }
    } else {
        print("Key not in map: {s}\n", .{key});
    }
    unreachable;
}

fn clearMap(map: *std.StringHashMap([]Rule)) void {
    var values = map.valueIterator();
    while (values.next()) |val| {
        gpa.free(val.*);
    }
}
pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});

    var chunks = mem.tokenizeSequence(u8, input, "\n\n");

    const workflowStr = chunks.next().?;
    var workflowMap = std.StringHashMap([]Rule).init(gpa);
    defer clearMap(&workflowMap);
    try parseWorkflows(&workflowMap, workflowStr);

    const partsStr = chunks.next().?;
    var partList = std.ArrayList(PartRating).init(gpa);
    defer partList.deinit();
    try parseParts(&partList, partsStr);

    var sum: usize = 0;
    for (partList.items) |part| {
        if (isAccepted(part, "in", workflowMap)) {
            sum += part.x + part.m + part.a + part.s;
        }
    }
    print("Answer: {d}\n", .{sum});
}
