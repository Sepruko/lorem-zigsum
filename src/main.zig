const std = @import("std");
const Lorem = @import("/lorem.zig").Lorem;

pub fn main() !u8 {
    const stdOut = std.io.getStdOut().writer();
    const stdIn = std.io.getStdIn().reader();

    stdOut.writeAll("How many words would you like to generate? ") catch unreachable;

    var buf: [32]u8 = undefined;
    var read_buf = stdIn.readUntilDelimiter(&buf, '\n') catch |err| {
        if (err == error.StreamTooLong) {
            stdOut.writeAll("Too long of an input.\n") catch unreachable;
        } else stdOut.writeAll("Failed to read into buffer.\n") catch unreachable;

        return 1;
    };

    if (read_buf[read_buf.len - 1] == '\r') read_buf.len -= 1;

    var amount = std.fmt.parseUnsigned(usize, read_buf, 10) catch {
        stdOut.writeAll("Failed to parse the given number.") catch unreachable;
        return 1;
    };

    try std.os.getrandom(read_buf[0..8]);
    var seed = @bitCast(u64, read_buf[0..8].*);
    var lorem = Lorem.init(seed);

    var generated_lorem_ipsum = try lorem.generateLoremIpsum(std.heap.c_allocator, amount);
    defer std.heap.c_allocator.free(generated_lorem_ipsum);

    stdOut.writeAll(generated_lorem_ipsum) catch unreachable;
    stdOut.writeAll("\n") catch unreachable;

    return 0;
}
