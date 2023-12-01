const std = @import("std");
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
    const input = try readFile("../input.txt");
    defer allocator.free(input);
    var first: usize = 0;
    var foundFirst = false;
    var last: usize = 0;
    var sum: usize = 0;
    var line_begin: usize = 0;
    var numStr: [2]u8 = undefined;
    var num: usize = 0;
    for (input, 0..input.len) |c, i| {
        if (std.ascii.isDigit(c)) {
            if (!foundFirst) {
                first = i;
                foundFirst = true;
            }
            last = i;
        }
        if (c == '\n' or i == input.len - 1) {
            numStr[0] = input[first];
            numStr[1] = input[last];
            num = try std.fmt.parseInt(usize, &numStr, 10);
            sum += num;
            foundFirst = false;
            line_begin = i + 1;
        }
    }
    print("Final sum: {d}\n", .{sum});
}
