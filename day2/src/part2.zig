const std = @import("std");
const print = std.debug.print;

// https://adventofcode.com/2023/day/2#part2

pub fn run(input: []const u8) !void {
    print("************\n", .{});
    print("   Part 2\n", .{});
    print("************\n", .{});
    var answer: usize = 0;
    // Loop over games
    var games = std.mem.tokenizeScalar(u8, input, '\n');
    while (games.next()) |game| {
        var game_split = std.mem.splitScalar(u8, game, ':');

        const id_str = game_split.next().?;
        const game_id = try std.fmt.parseInt(u32, id_str[5..], 10);
        _ = game_id;

        var game_record = game_split.next().?;
        game_record = std.mem.trim(u8, game_record, &std.ascii.whitespace);

        var draws = std.mem.splitScalar(u8, game_record, ';');

        // parse each draw in the game
        var min_red: u32 = 0;
        var min_green: u32 = 0;
        var min_blue: u32 = 0;
        while (draws.next()) |draw| {
            var cube_set = std.mem.splitScalar(u8, draw, ',');
            // Parse each set of '<count> <color>'
            while (cube_set.next()) |cube_info| {
                var info = std.mem.tokenizeScalar(u8, cube_info, ' ');
                const count = try std.fmt.parseInt(u32, info.next().?, 10);
                const color = info.next().?;
                if (color[0] == 'r') {
                    if (count > min_red) {
                        min_red = count;
                    }
                } else if (color[0] == 'g') {
                    if (count > min_green) {
                        min_green = count;
                    }
                } else if (color[0] == 'b') {
                    if (count > min_blue) {
                        min_blue = count;
                    }
                }
            }
        }
        answer += min_red * min_green * min_blue;
    }

    print("Final answer: {d}\n", .{answer});
}
