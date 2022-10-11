const std = @import("std");

/// A slice of latin words to use.
pub const latin_words = &[_][]const u8{
    "a",
    "ac",
    "adipiscing",
    "aliquam",
    "amet",
    "ante",
    "arcu",
    "at",
    "auctor",
    "augue",
    "bibendum",
    "condimentum",
    "consectetuer",
    "consequat",
    "cursus",
    "diam",
    "dolor",
    "dui",
    "duis",
    "egestas",
    "eget",
    "eleifend",
    "elementum",
    "elit",
    "enim",
    "eros",
    "est",
    "et",
    "felis",
    "fusce",
    "gravida",
    "id",
    "imperdiet",
    "in",
    "ipsum",
    "justo",
    "lacus",
    "laoreet",
    "lectus",
    "leo",
    "lorem",
    "maecenas",
    "magna",
    "massa",
    "mattis",
    "mauris",
    "metus",
    "mi",
    "morbi",
    "nam",
    "nibh",
    "nisl",
    "non",
    "nonummy",
    "nulla",
    "nullam",
    "nunc",
    "odio",
    "orci",
    "placerat",
    "posuere",
    "praesent",
    "quis",
    "rhoncus",
    "sed",
    "sem",
    "sit",
    "sollicitudin",
    "suspendisse",
    "tellus",
    "tincidunt",
    "ut",
    "vehicula",
    "velit",
    "vestibulum",
    "vitae",
    "vivamus",
    "viverra",
    "vulputate",
};

/// A slice of punctuation to use.
pub const punctuation_chars = &[_]u8{
    '\n',
    '!',
    ',',
    '-',
    '.',
    ':',
    ';',
    '?',
};

/// Generates a string of lorem ipsum.
pub const LoremIpsumGenerator = struct {
    xosh: std.rand.Xoshiro256,
    random: std.rand.Random,

    const Error = error{
        BufferTooLarge,
        NoWords,
    } || std.mem.Allocator.Error;

    /// Initializes a new instance of `LoremIpsumGenerator` with the given seed.
    pub fn init(seed: u64) LoremIpsumGenerator {
        var xosh = std.rand.DefaultPrng.init(seed);
        return .{
            .xosh = xosh,
            .random = xosh.random(),
        };
    }

    /// Returns a random punctuation from `punctuation_chars`.
    pub inline fn randomPunctuation(self: *LoremIpsumGenerator) u8 {
        return punctuation_chars[self.random.uintLessThanBiased(usize, punctuation_chars.len)];
    }

    /// Returns a random word from `latin_words`.
    pub inline fn randomLatin(self: *LoremIpsumGenerator) []const u8 {
        return latin_words[self.random.uintLessThanBiased(usize, latin_words.len)];
    }

    /// Generates a number of words, the caller owns the returned memory and must free it.
    ///
    /// The force argument is only used if the resulting required allocation size for the inital
    // buffer is larger than 32 megabytes.
    pub fn generateLoremIpsum(
        self: *LoremIpsumGenerator,
        allocator: std.mem.Allocator,
        count: usize,
        max_size: ?usize,
    ) LoremIpsumGenerator.Error![]u8 {
        // TODO: Consider using a temporary file to write our stuff to if the required size is above
        // a threshold.
        //
        // I would do this *now*, however I cannot be bothered handle temporary files on each target
        // OS.

        if (count == 0) return Error.NoWords;

        const required_size = 1024 * @as(usize, if (count < 10) 1 else count / 10);
        if (max_size != null and required_size > max_size.?)
            return Error.BufferTooLarge;

        var buffer = try allocator.alloc(u8, required_size);
        defer allocator.free(buffer);

        var fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(buffer);
        var alloc = fixed_buffer_allocator.allocator();

        var word_and_punctuation_list = std.ArrayList([]const u8).init(allocator);
        defer word_and_punctuation_list.deinit();

        var current_word_count: usize = 0;
        var need_capitalized_word = true;

        while (current_word_count < count) : (current_word_count += 1) {
            // Insert a new punctuation character.
            if (@rem(current_word_count, 8) == 6) {
                // De-incremement the items length to correct.
                word_and_punctuation_list.items.len -= 1;

                switch (self.randomPunctuation()) {
                    '-' => |ch| {
                        var item = try alloc.alloc(u8, 1);
                        item[0] = ch;

                        // The words should be joined.
                        try word_and_punctuation_list.append(item);
                    },
                    '\n' => |ch| {
                        var item = try alloc.alloc(u8, 3);
                        item[0] = '.';
                        item[1] = ch;
                        item[2] = ch;

                        try word_and_punctuation_list.append(item);
                        need_capitalized_word = true;
                    },
                    else => |ch| {
                        var item = try alloc.alloc(u8, 2);
                        item[0] = ch;
                        item[1] = ' ';

                        try word_and_punctuation_list.append(item);
                        need_capitalized_word = switch (ch) {
                            '.', '?', '!', ':' => true,
                            else => false,
                        };
                    },
                }
            }

            var random_latin = try alloc.dupe(u8, self.randomLatin());
            if (need_capitalized_word) {
                random_latin[0] -= 32;
                need_capitalized_word = false;
            }

            var slice = try alloc.alloc([]const u8, 2);
            slice[0] = random_latin;
            slice[1] = if (current_word_count == count - 1) "." else " ";

            try word_and_punctuation_list.appendSlice(slice);
        }

        return std.mem.join(allocator, "", word_and_punctuation_list.items);
    }
};
