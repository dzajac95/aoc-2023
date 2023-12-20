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

const Workflow = std.ArrayList(Rule);

fn parseWorkflows(map: *std.StringHashMap(Workflow), str: []const u8) !void {
    _ = map;
    var lines = mem.tokenizeScalar(u8, str, '\n');
    var wf = Workflow.init(gpa);
    while (lines.next()) |line| {
        const wfStart = mem.indexOfScalar(u8, line, '{').?;
        const wfEnd = mem.indexOfScalar(u8, line, '}').?;
        const id = line[0..wfStart];
        _ = id;
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

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    var chunks = mem.tokenizeSequence(u8, input, "\n\n");
    const workflowStr = chunks.next().?;
    const partsStr = chunks.next().?;
    var workflowMap = std.StringHashMap(Workflow).init(gpa);
    var partList = std.ArrayList(PartRating).init(gpa);
    try parseWorkflows(&workflowMap, workflowStr);
    try parseParts(&partList, partsStr);
    for (partList.items) |part| {
        print("part: {}\n", .{part});
    }
}
