const std = @import("std");

const all_targets = &[_]std.zig.CrossTarget{
    .{ .os_tag = .macos, .cpu_arch = .aarch64 },
    .{ .os_tag = .macos, .cpu_arch = .x86_64 },
    .{ .os_tag = .linux, .cpu_arch = .aarch64 },
    .{ .os_tag = .linux, .cpu_arch = .i386 },
    .{ .os_tag = .linux, .cpu_arch = .x86_64 },
    .{ .os_tag = .windows, .cpu_arch = .aarch64 },
    // .{ .os_tag = .windows, .cpu_arch = .i386 },
    .{ .os_tag = .windows, .cpu_arch = .x86_64 },
};

pub fn build(builder: *std.build.Builder) !void {
    const bin_target = builder.standardTargetOptions(.{});
    const bin_mode = builder.standardReleaseOptions();

    const strip_bin = builder.option(bool, "strip", "Whether to strip any resulting binaries.") orelse (bin_mode == .ReleaseFast);

    const all_step = builder.step("all", "Build for all targets.");
    inline for (all_targets) |target| {
        const target_bin = builder.addExecutable(std.fmt.comptimePrint("ipsum_{s}_{s}", .{ @tagName(target.cpu_arch.?), @tagName(target.os_tag.?) }), "src/main.zig");
        target_bin.strip = strip_bin;

        target_bin.linkLibC();

        target_bin.setBuildMode(bin_mode);
        target_bin.setTarget(target);

        all_step.dependOn(&builder.addInstallArtifact(target_bin).step);
    }

    const bin = builder.addExecutable("ipsum", "src/main.zig");
    bin.strip = strip_bin;

    bin.linkLibC();

    bin.setBuildMode(bin_mode);
    bin.setTarget(bin_target);

    bin.install();
}
