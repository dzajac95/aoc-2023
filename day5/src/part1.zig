const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/5

const Mapping = struct {
    dstStart: usize,
    srcStart: usize,
    range: usize,

    pub fn fromLine(line: []const u8) !Mapping {
        var iter = mem.tokenizeScalar(u8, line, ' ');
        const dstStr = iter.next() orelse return error.ParseError;
        const srcStr = iter.next() orelse return error.ParseError;
        const rangeStr = iter.next() orelse return error.ParseError;
        const dst = try fmt.parseInt(usize, dstStr, 10);
        const src = try fmt.parseInt(usize, srcStr, 10);
        const range = try fmt.parseInt(usize, rangeStr, 10);
        return Mapping{
            .dstStart = dst,
            .srcStart = src,
            .range = range,
        };
    }

    pub fn print(self: Mapping) void {
        std.debug.print("src start: {d} dst start: {d} range: {d}\n", .{ self.srcStart, self.dstStart, self.range });
    }

    pub fn contains(self: Mapping, num: usize) bool {
        return num >= self.srcStart and num <= self.srcStart + self.range;
    }
};

fn getMapping(mappings: []const Mapping, target: usize) ?Mapping {
    for (mappings) |mapping| {
        if (mapping.contains(target)) {
            return mapping;
        }
    }
    return null;
}

fn parseMappings(chunkStr: []const u8, mappings: *std.ArrayList(Mapping)) !void {
    var lines = mem.tokenizeScalar(u8, chunkStr, '\n');
    _ = lines.next();
    // parse out mapping ranges:
    // <dstStart> <srcStart> <range>
    while (lines.next()) |line| {
        const m = try Mapping.fromLine(line);
        try mappings.*.append(m);
    }
}

const IdMap = std.AutoHashMap(usize, usize);

fn mapFromMap(src: IdMap, dst: *IdMap, mappings: []const Mapping) !void {
    var srcValues = src.valueIterator();
    while (srcValues.next()) |pNum| {
        const num = pNum.*;
        if (getMapping(mappings, num)) |map| {
            const destNum = map.dstStart + (num - map.srcStart);
            try dst.put(num, destNum);
        } else {
            try dst.put(num, num);
        }
    }
}

fn mapFromList(src: []const usize, dst: *IdMap, mappings: []const Mapping) !void {
    for (src) |num| {
        if (getMapping(mappings, num)) |map| {
            const destNum = map.dstStart + (num - map.srcStart);
            try dst.put(num, destNum);
        } else {
            try dst.put(num, num);
        }
    }
}

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 1\n", .{});
    print("************\n", .{});
    // Split input into discrete chunks (seeds, seed-to-soil map, etc.)
    var chunks = mem.tokenizeSequence(u8, input, "\n\n");

    var mappings = std.ArrayList(Mapping).init(gpa);
    // Process seed numbers in the format:
    // seeds: x y z a b c ...
    const seedsStr = chunks.next().?;
    var seedSplit = mem.splitSequence(u8, seedsStr, ": ");
    _ = seedSplit.first();
    const seedNumStr = seedSplit.next().?;
    var seedNumSplit = mem.tokenizeScalar(u8, seedNumStr, ' ');
    var seedNums = std.ArrayList(usize).init(gpa);
    print("Seed nums:\n", .{});
    while (seedNumSplit.next()) |numStr| {
        print("{s}\n", .{numStr});
        const num = try fmt.parseInt(usize, numStr, 10);
        try seedNums.append(num);
    }

    // Process seed-to-soil map
    const seedToSoilChunk = chunks.next().?;
    try parseMappings(seedToSoilChunk, &mappings);
    var seedToSoil = IdMap.init(gpa);
    try mapFromList(seedNums.items, &seedToSoil, mappings.items);
    print("Seed to soil:\n", .{});
    { // print map
        var iter = seedToSoil.iterator();
        while (iter.next()) |entry| {
            print("Entry: {d} -> {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
    }

    // soil-to-fertilizer
    mappings.clearAndFree();
    const soilToFertChunk = chunks.next().?;
    var soilToFert = IdMap.init(gpa);
    try parseMappings(soilToFertChunk, &mappings);
    try mapFromMap(seedToSoil, &soilToFert, mappings.items);
    print("Soil to fertilizer:\n", .{});
    { // print map
        var iter = soilToFert.iterator();
        while (iter.next()) |entry| {
            print("Entry: {d} -> {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
    }

    // fertilizer-to-water
    mappings.clearAndFree();
    const fertToWaterChunk = chunks.next().?;
    var fertToWater = IdMap.init(gpa);
    try parseMappings(fertToWaterChunk, &mappings);
    try mapFromMap(soilToFert, &fertToWater, mappings.items);

    // water-to-light
    mappings.clearAndFree();
    const waterToLightChunk = chunks.next().?;
    var waterToLight = IdMap.init(gpa);
    try parseMappings(waterToLightChunk, &mappings);
    try mapFromMap(fertToWater, &waterToLight, mappings.items);

    // light-to-temperature
    mappings.clearAndFree();
    const lightToTempChunk = chunks.next().?;
    var lightToTemp = IdMap.init(gpa);
    try parseMappings(lightToTempChunk, &mappings);
    try mapFromMap(waterToLight, &lightToTemp, mappings.items);

    // temperature-to-humidity
    mappings.clearAndFree();
    const tempToHumidityChunk = chunks.next().?;
    var tempToHumidity = IdMap.init(gpa);
    try parseMappings(tempToHumidityChunk, &mappings);
    try mapFromMap(lightToTemp, &tempToHumidity, mappings.items);

    // humidity-to-location
    mappings.clearAndFree();
    const humidityToLocChunk = chunks.next().?;
    var humidityToLoc = IdMap.init(gpa);
    try parseMappings(humidityToLocChunk, &mappings);
    try mapFromMap(tempToHumidity, &humidityToLoc, mappings.items);

    var closestLoc: usize = std.math.maxInt(usize);
    print("Humidity to location:\n", .{});
    { // find closest location
        var iter = humidityToLoc.iterator();
        var value: usize = 0;
        while (iter.next()) |entry| {
            value = entry.value_ptr.*;
            if (value <= closestLoc) {
                closestLoc = value;
            }
            print("Entry: {d} -> {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
    }
    print("Closest location: {d}\n", .{closestLoc});
}
