const std = @import("std");
const Lorem = @import("lorem.zig").Lorem;

pub fn main() !u8 {
    const std_out = std.io.getStdOut().writer();
    const std_in = std.io.getStdIn().reader();

    std_out.writeAll("How many words would you like to generate? ") catch unreachable;

    var buf: [32]u8 = undefined;
    var read_buf = std_in.readUntilDelimiter(&buf, '\n') catch |err| {
        if (err == error.StreamTooLong) {
            std_out.writeAll("Too long of an input.\n") catch unreachable;
        } else std_out.writeAll("Failed to read into buffer.\n") catch unreachable;

        return 1;
    };

    if (read_buf[read_buf.len - 1] == '\r') read_buf.len -= 1;

    var amount = std.fmt.parseUnsigned(usize, read_buf, 10) catch {
        std_out.writeAll("Failed to parse the given number.") catch unreachable;
        return 1;
    };

    try std.os.getrandom(buf[0..8]);
    var seed = @bitCast(u64, buf[0..8].*);
    var lorem = Lorem.init(seed);

    var generated_lorem_ipsum = try lorem.generateLoremIpsum(std.heap.c_allocator, amount);
    defer std.heap.c_allocator.free(generated_lorem_ipsum);

    std_out.writeAll(generated_lorem_ipsum) catch unreachable;
    std_out.writeAll("\n") catch unreachable;

    return 0;
}
