const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    mod.addCSourceFile(.{
        .file = b.path("glad/src/glad.c"),
    });

    mod.addIncludePath(b.path("glad/include"));

    const lib = b.addLibrary(.{
        .name = "glad",
        .root_module = mod,
    });

    lib.installHeadersDirectory(b.path("glad/include/glad"), "glad", .{});
    lib.installHeadersDirectory(b.path("glad/include/KHR"), "KHR", .{});

    b.installArtifact(lib);
}
