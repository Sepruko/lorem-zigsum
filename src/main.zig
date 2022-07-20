const std = @import("std");

pub fn main() !u8 {
    std.io.getStdOut().writeAll("Hello, World!") catch return 1;
    return 0;
}
