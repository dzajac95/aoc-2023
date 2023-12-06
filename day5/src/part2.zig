const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ascii = std.ascii;

// https://adventofcode.com/2023/day/5#part2

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
        std.debug.print("src: {d} dst: {d} range: {d}\n", .{ self.srcStart, self.dstStart, self.range });
    }

    pub fn contains(self: Mapping, num: usize) bool {
        return num >= self.srcStart and num <= self.srcStart + self.range;
    }
};

const IdMap = struct {
    mappings: std.ArrayList(Mapping),

    pub fn init(allocator: mem.Allocator) IdMap {
        return IdMap{
            .mappings = std.ArrayList(Mapping).init(allocator),
        };
    }

    pub fn deinit(self: IdMap) void {
        self.mappings.deinit();
    }

    pub fn parseMappings(self: *IdMap, chunkStr: []const u8) !void {
        var lines = mem.tokenizeScalar(u8, chunkStr, '\n');
        _ = lines.next();
        // parse out mapping ranges:
        // <dstStart> <srcStart> <range>
        while (lines.next()) |line| {
            const m = try Mapping.fromLine(line);
            try self.mappings.append(m);
        }
    }

    fn getMapping(self: IdMap, target: usize) ?Mapping {
        for (self.mappings.items) |mapping| {
            if (mapping.contains(target)) {
                return mapping;
            }
        }
        return null;
    }

    pub fn get(self: IdMap, key: usize) usize {
        if (self.getMapping(key)) |map| {
            const destNum = map.dstStart + (key - map.srcStart);
            return destNum;
        } else {
            return key;
        }
    }

    pub fn print(self: IdMap) void {
        for (self.mappings.items) |map| {
            map.print();
        }
    }
};

const MapChain = struct {
    seedToSoil: IdMap,
    soilToFert: IdMap,
    fertToWater: IdMap,
    waterToLight: IdMap,
    lightToTemp: IdMap,
    tempToHumidity: IdMap,
    humidityToLoc: IdMap,

    pub fn init(allocator: mem.Allocator) MapChain {
        return MapChain{
            .seedToSoil = IdMap.init(allocator),
            .soilToFert = IdMap.init(allocator),
            .fertToWater = IdMap.init(allocator),
            .waterToLight = IdMap.init(allocator),
            .lightToTemp = IdMap.init(allocator),
            .tempToHumidity = IdMap.init(allocator),
            .humidityToLoc = IdMap.init(allocator),
        };
    }

    pub fn parse(self: *MapChain, text: []const u8) !void {
        var chunks = mem.tokenizeSequence(u8, text, "\n\n");

        // seed-to-soil map
        const seedToSoilChunk = chunks.next().?;
        try self.seedToSoil.parseMappings(seedToSoilChunk);

        // soil-to-fertilizer map
        const soilToFertChunk = chunks.next().?;
        try self.soilToFert.parseMappings(soilToFertChunk);

        // fertilizer-to-water
        const fertToWaterChunk = chunks.next().?;
        try self.fertToWater.parseMappings(fertToWaterChunk);

        // water-to-light
        const waterToLightChunk = chunks.next().?;
        try self.waterToLight.parseMappings(waterToLightChunk);

        // light-to-temperature
        const lightToTempChunk = chunks.next().?;
        try self.lightToTemp.parseMappings(lightToTempChunk);

        // temperature-to-humidity
        const tempToHumidityChunk = chunks.next().?;
        try self.tempToHumidity.parseMappings(tempToHumidityChunk);

        // humidity-to-location
        const humidityToLocChunk = chunks.next().?;
        try self.humidityToLoc.parseMappings(humidityToLocChunk);
    }

    pub fn getLoc(self: MapChain, seed: usize) usize {
        const soil = self.seedToSoil.get(seed);
        const fert = self.soilToFert.get(soil);
        const water = self.fertToWater.get(fert);
        const light = self.waterToLight.get(water);
        const temp = self.lightToTemp.get(light);
        const humidity = self.tempToHumidity.get(temp);
        const loc = self.humidityToLoc.get(humidity);
        return loc;
    }

    pub fn printChain(self: MapChain, seed: usize) void {
        print("{d} -> ", .{seed});
        const soil = self.seedToSoil.get(seed);
        print("{d} -> ", .{soil});
        const fert = self.soilToFert.get(soil);
        print("{d} -> ", .{fert});
        const water = self.fertToWater.get(fert);
        print("{d} -> ", .{water});
        const light = self.waterToLight.get(water);
        print("{d} -> ", .{light});
        const temp = self.lightToTemp.get(light);
        print("{d} -> ", .{temp});
        const humidity = self.tempToHumidity.get(temp);
        print("{d} -> ", .{humidity});
        const loc = self.humidityToLoc.get(humidity);
        print("{d}\n", .{loc});
    }

    pub fn deinit(self: MapChain) void {
        self.seedToSoil.deinit();
        self.soilToFert.deinit();
        self.fertToWater.deinit();
        self.waterToLight.deinit();
        self.lightToTemp.deinit();
        self.tempToHumidity.deinit();
        self.humidityToLoc.deinit();
    }
};

const SeedRange = struct {
    start: usize,
    end: usize,
};

pub fn run(input: []const u8) !void {
    var gpaObj = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpaObj.allocator();
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});

    // Split input into discrete chunks (seeds, seed-to-soil map, etc.)
    var chunks = mem.tokenizeSequence(u8, input, "\n\n");

    // Process seed numbers in the format:
    // seeds: x xLen y yLen z zLen

    const seedsStr = chunks.next().?;
    var seedSplit = mem.splitSequence(u8, seedsStr, ": ");
    _ = seedSplit.first();
    const seedNumStr = seedSplit.next().?;
    var seedNumSplit = mem.tokenizeScalar(u8, seedNumStr, ' ');

    // First get the numbers into a list
    var seedNums = std.ArrayList(usize).init(gpa);
    defer seedNums.deinit();
    while (seedNumSplit.next()) |numStr| {
        const num = try fmt.parseInt(usize, numStr, 10);
        try seedNums.append(num);
    }

    // Then take pairs and convert to ranges
    std.debug.assert(seedNums.items.len % 2 == 0);
    var seedRanges = std.ArrayList(SeedRange).init(gpa);
    defer seedRanges.deinit();
    var i: usize = 0;
    print("Seed ranges:\n", .{});
    while (i < seedNums.items.len) {
        const start = seedNums.items[i];
        const len = seedNums.items[i + 1];
        const end = start + seedNums.items[i + 1];
        print("{d}, {d}, {d}\n", .{ start, len, end });
        try seedRanges.append(.{
            .start = start,
            .end = end,
        });
        i += 2;
    }
    var maps = MapChain.init(gpa);
    defer maps.deinit();

    try maps.parse(chunks.rest());

    var closestLoc: usize = std.math.maxInt(usize);
    for (seedRanges.items) |range| {
        for (range.start..range.end) |seed| {
            const loc = maps.getLoc(seed);
            if (loc < closestLoc) {
                closestLoc = loc;
            }
        }
    }
    print("Closest location: {d}\n", .{closestLoc});
}
