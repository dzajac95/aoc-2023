const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
// const input =
//     \\fouronevhnrz44
//     \\eightg1
//     \\4ninejfpd1jmmnnzjdtk5sjfttvgtdqspvmnhfbm
//     \\78seven8
//     \\6pcrrqgbzcspbd
//     \\7sevenseven
//     \\1threeeight66
//     \\one1sevensskhdreight
//     \\rninethree6
//     \\eight45fourfgfive1
//     \\1
// ;

pub fn main() !void {
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
            const line = input[line_begin..i];
            sum += num;
            print("{s:60}  pair: {d},{d}  num: {d}\n", .{ line, first, last, num });
            foundFirst = false;
            line_begin = i + 1;
        }
    }
    print("Final sum: {d}\n", .{sum});
}
