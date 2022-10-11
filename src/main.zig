const std = @import("std");

const LoremIpsumGenerator = @import("lorem.zig").LoremIpsumGenerator;

const help =
    \\Ziggy Ipsum, a lorem ipsum generator written in Zig.
    \\
    \\Usage:
    \\
    \\ipsum <number>
    \\
    \\Flags:
    \\  -f, --force Force memory allocations larger than 32 (thirty-two) megabytes.
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

    var amount = get_amount: {
        for (args[1..]) |arg| break :get_amount std.fmt.parseUnsigned(usize, arg, 10) catch continue;

        std_err.writeAll(help) catch unreachable;
        return 1;
    };

    var force = get_force: {
        for (args[1..]) |arg| break :get_force if (std.mem.eql(u8, arg, "-f") or std.mem.eql(u8, arg, "--force")) true else continue;

        break :get_force false;
    };

    var buf: [8]u8 = undefined;
    try std.os.getrandom(&buf);
    var generator = LoremIpsumGenerator.init(@bitCast(u64, buf));

    // var gpa_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa_alloc.deinit();
    var allocator = std.heap.c_allocator; // gpa_alloc.allocator();

    var generated_lorem_ipsum = generator.generateLoremIpsum(allocator, amount, force) catch |err| switch (err) {
        error.BufferTooLarge => prompt_force: {
            var std_in = std.io.getStdIn().reader();

            try std_err.writeAll(
                "Refusing to allocate more than 32MB (thirty-two megabytes) of memory, force generation? (y/N) ",
            );

            var read = try std_in.readUntilDelimiterAlloc(allocator, '\n', 4);
            defer allocator.free(read);

            // Hide carriage-return.
            if (read[read.len - 1] == '\r') read.len -= 1;

            if (std.ascii.eqlIgnoreCase(read, "Y") or std.ascii.eqlIgnoreCase(read, "Yes")) {
                break :prompt_force try generator.generateLoremIpsum(allocator, amount, true);
            }

            try std_err.print("Cancelled printing {d} words.\n", .{amount});
            return 1;
        },
        else => {
            try std_err.print("Failed to generate the requested {d} words: {!}\n", .{ amount, err });
            return 1;
        },
    };
    defer allocator.free(generated_lorem_ipsum);

    std_out.print("{s}\n", .{generated_lorem_ipsum}) catch unreachable;

    return 0;
}
