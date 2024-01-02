const std = @import("std");
const lorem = @import("lorem-zigsum");

pub fn main() !void {
    const std_out = std.io.getStdOut().writer();
    try std_out.writeAll(lorem.x);
}
