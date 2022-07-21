const std = @import("std");

pub const latin_slice = &[_][]const u8{ "lorem", "ipsum", "dolor", "sit", "amet", "consectetuer", "adipiscing", "elit", "nam", "cursus", "morbi", "ut", "mi", "nullam", "enim", "leo", "egestas", "id", "condimentum", "at", "laoreet", "mattis", "massa", "sed", "eleifend", "nonummy", "diam", "praesent", "mauris", "ante", "elementum", "et", "bibendum", "at", "posuere", "sit", "amet", "nibh", "duis", "tincidunt", "lectus", "quis", "dui", "viverra", "vestibulum", "suspendisse", "vulputate", "aliquam", "dui", "nulla", "elementum", "dui", "ut", "augue", "aliquam", "vehicula", "mi", "at", "mauris", "maecenas", "placerat", "nisl", "at", "consequat", "rhoncus", "sem", "nunc", "gravida", "justo", "quis", "eleifend", "arcu", "velit", "quis", "lacus", "morbi", "magna", "magna", "tincidunt", "a", "mattis", "non", "imperdiet", "vitae", "tellus", "sed", "odio", "est", "auctor", "ac", "sollicitudin", "in", "consequat", "vitae", "orci", "fusce", "id", "felis", "vivamus", "sollicitudin", "metus", "eget", "eros" };

pub const punctuation_slice = &[_]u8{ '.', ',', ';', ':', '?', '!', '-', '\n' };

pub const Lorem = struct {
    xosh: std.rand.Xoshiro256,
    random: std.rand.Random,

    pub fn init(seed: u64) Lorem {
        var xosh = std.rand.DefaultPrng.init(seed);
        return .{
            .xosh = xosh,
            .random = xosh.random(),
        };
    }

    pub inline fn randomPunctuation(self: *Lorem) u8 {
        return punctuation_slice[self.random.uintLessThanBiased(usize, punctuation_slice.len)];
    }

    pub inline fn randomLatin(self: *Lorem) []const u8 {
        return latin_slice[self.random.uintLessThanBiased(usize, latin_slice.len)];
    }

    /// Generates a number of words, the caller owns the returned memory and must free it.
    pub fn generateLoremIpsum(self: *Lorem, allocator: std.mem.Allocator, words: usize) ![]u8 {
        var list = std.ArrayList([]const u8).init(allocator);
        defer list.deinit();

        var i: usize = 0;
        var need_capitalised = true;
        while (i < words) : (i += 1) {
            if (@rem(i, 8) == 6) {
                list.items.len -= 1;
                var punctuation = self.randomPunctuation();
                switch (punctuation) {
                    '-' => try list.append(&[_]u8{punctuation}),
                    '\n' => {
                        try list.append(&[_]u8{ '.', punctuation, punctuation });
                        need_capitalised = true;
                    },
                    '.', '?', '!', ':' => {
                        try list.append(&[_]u8{ punctuation, ' ' });
                        need_capitalised = true;
                    },
                    else => try list.append(&[_]u8{ punctuation, ' ' }),
                }
            }

            if (need_capitalised) {
                var random_latin = self.randomLatin();
                try list.appendSlice(&[_][]const u8{
                    &[_]u8{random_latin[0] - 32},
                    random_latin[1..],
                    if (i == words - 1) "." else " ",
                });
                need_capitalised = false;
            } else {
                try list.appendSlice(&[_][]const u8{
                    self.randomLatin(),
                    if (i == words - 1) "." else " ",
                });
            }
        }

        return std.mem.join(allocator, "", list.items);
    }
};
