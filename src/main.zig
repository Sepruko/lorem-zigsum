const std = @import("std");
const Lorem = @import("lorem.zig").Lorem;

const help =
    \\Ziggy Ipsum, a lorem ipsum generator written in Zig.
    \\
    \\Usage:
    \\
    \\ipsum <number>
    \\
;

pub fn main() !u8 {
    const std_out = std.io.getStdOut().writer();
    const std_err = std.io.getStdErr().writer();

    var args = std.process.argsAlloc(std.heap.c_allocator) catch {
        std_err.writeAll("Failed to process arguments.\n") catch unreachable;
        return 1;
    };

    if (args.len < 2) {
        std_err.writeAll(help) catch unreachable;
        return 1;
    }

    var amount = std.fmt.parseUnsigned(usize, args[1], 10) catch {
        std_err.writeAll(help) catch unreachable;
        return 1;
    };

    var buf: [8]u8 = undefined;
    try std.os.getrandom(&buf);
    var lorem = Lorem.init(@bitCast(u64, buf));

    var generated_lorem_ipsum = try lorem.generateLoremIpsum(std.heap.c_allocator, amount);
    defer std.heap.c_allocator.free(generated_lorem_ipsum);

    std_out.print("{s}\n", .{generated_lorem_ipsum}) catch unreachable;

    return 0;
}
