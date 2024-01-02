const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_lorem = b.addStaticLibrary(.{
        .name = "lorem-zigsum",
        .root_source_file = .{ .path = "src/lorem.zig" },
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 2, .minor = 0, .patch = 0 },
    });
    const lib_lorem_step = b.step("lib", "Build static library");
    lib_lorem_step.dependOn(&b.addInstallArtifact(lib_lorem, .{}).step);

    const dyn_lorem = b.addSharedLibrary(.{
        .name = "lorem-zigsum",
        .root_source_file = .{ .path = "src/lorem.zig" },
        .target = target,
        .optimize = optimize,
    });
    const dyn_lorem_step = b.step("dyn", "Build dynamic library");
    dyn_lorem_step.dependOn(&b.addInstallArtifact(dyn_lorem, .{}).step);

    const mod_lorem = b.addModule("lorem-zigsum", .{
        .source_file = .{ .path = "src/lorem.zig" },
    });

    const cli_lorem = b.addExecutable(.{
        .name = "lorem",
        .root_source_file = .{ .path = "cli/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    cli_lorem.addModule("lorem-zigsum", mod_lorem);
    const cli_lorem_step = b.step("cli", "Build CLI");
    cli_lorem_step.dependOn(&b.addInstallArtifact(cli_lorem, .{}).step);
}
