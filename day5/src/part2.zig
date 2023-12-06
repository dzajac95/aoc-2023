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

    pub fn containsSrc(self: Mapping, num: usize) bool {
        return num >= self.srcStart and num < self.srcStart + self.range;
    }

    pub fn containsDst(self: Mapping, num: usize) bool {
        return num >= self.dstStart and num < self.dstStart + self.range;
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

    fn getMappingBySrc(self: IdMap, target: usize) ?Mapping {
        for (self.mappings.items) |mapping| {
            if (mapping.containsSrc(target)) {
                return mapping;
            }
        }
        return null;
    }

    fn getMappingByDst(self: IdMap, target: usize) ?Mapping {
        for (self.mappings.items) |mapping| {
            if (mapping.containsDst(target)) {
                return mapping;
            }
        }
        return null;
    }
    pub fn getDst(self: IdMap, src: usize) usize {
        if (self.getMappingBySrc(src)) |map| {
            const destNum = map.dstStart + (src - map.srcStart);
            return destNum;
        } else {
            return src;
        }
    }

    pub fn getSrc(self: IdMap, dst: usize) usize {
        if (self.getMappingByDst(dst)) |map| {
            const srcNum = map.srcStart + (dst - map.dstStart);
            return srcNum;
        } else {
            return dst;
        }
    }

    pub fn print(self: IdMap) void {
        for (self.mappings.items) |map| {
            map.print();
        }
    }
};

fn mapDstLt(_: void, lhs: Mapping, rhs: Mapping) bool {
    return lhs.dstStart < rhs.dstStart;
}

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
        const soil = self.seedToSoil.getDst(seed);
        const fert = self.soilToFert.getDst(soil);
        const water = self.fertToWater.getDst(fert);
        const light = self.waterToLight.getDst(water);
        const temp = self.lightToTemp.getDst(light);
        const humidity = self.tempToHumidity.getDst(temp);
        const loc = self.humidityToLoc.getDst(humidity);
        return loc;
    }

    pub fn seedFromLoc(self: MapChain, loc: usize) usize {
        const humidity = self.humidityToLoc.getSrc(loc);
        const temp = self.tempToHumidity.getSrc(humidity);
        const light = self.lightToTemp.getSrc(temp);
        const water = self.waterToLight.getSrc(light);
        const fert = self.fertToWater.getSrc(water);
        const soil = self.soilToFert.getSrc(fert);
        const seed = self.seedToSoil.getSrc(soil);
        return seed;
    }

    pub fn printChain(self: MapChain, seed: usize) void {
        print("{d} -> ", .{seed});
        const soil = self.seedToSoil.getDst(seed);
        print("{d} -> ", .{soil});
        const fert = self.soilToFert.getDst(soil);
        print("{d} -> ", .{fert});
        const water = self.fertToWater.getDst(fert);
        print("{d} -> ", .{water});
        const light = self.waterToLight.getDst(water);
        print("{d} -> ", .{light});
        const temp = self.lightToTemp.getDst(light);
        print("{d} -> ", .{temp});
        const humidity = self.tempToHumidity.getDst(temp);
        print("{d} -> ", .{humidity});
        const loc = self.humidityToLoc.getDst(humidity);
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

    pub fn contains(self: SeedRange, seed: usize) bool {
        return seed >= self.start and seed < self.end;
    }
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

    // Sort so that location ranges are in ascending order
    mem.sort(Mapping, maps.humidityToLoc.mappings.items, {}, mapDstLt);
    var closestLoc: usize = std.math.maxInt(usize);
    // Iterate over location ranges
    outer: for (maps.humidityToLoc.mappings.items) |locMap| {
        // iterate over locations within range
        for (locMap.dstStart..locMap.dstStart + locMap.range) |loc| {
            // get seed ID from the given location
            const seedID = maps.seedFromLoc(loc);
            // check if seed exists in any of the provided seed ranges
            for (seedRanges.items) |range| {
                if (range.contains(seedID)) {
                    closestLoc = loc;
                    break :outer;
                }
            }
        }
    }
    print("Closest location: {d}\n", .{closestLoc});
}
