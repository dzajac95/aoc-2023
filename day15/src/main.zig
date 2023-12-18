const std = @import("std");
const part1 = @import("part1.zig").run;
const part2 = @import("part2.zig").run;

const print = std.debug.print;
const allocator = std.heap.page_allocator;

fn readFile(file_path: []const u8) ![]u8 {
    const path = try std.fs.realpathAlloc(allocator, file_path);
    defer allocator.free(path);
    const input_file = try std.fs.openFileAbsolute(path, .{});
    defer input_file.close();
    const stat = try input_file.stat();
    const file_size = stat.size;
    var input: []u8 = try allocator.alloc(u8, file_size);
    _ = try input_file.read(input);
    return input;
}

pub fn main() !void {
    // Read in file
    const input = try readFile("sample.txt");
    defer allocator.free(input);
    var args = std.process.args();
    _ = args.next().?;
    if (args.next()) |subcmd| {
        if (std.mem.eql(u8, subcmd, "part1")) {
            try part1(input);
        } else if (std.mem.eql(u8, subcmd, "part2")) {
            try part2(input);
        } else {
            print("Unkown subcommand: {s}\n", .{subcmd});
        }
    } else {
        try part1(input);
        print("\n", .{});
        try part2(input);
    }
}
