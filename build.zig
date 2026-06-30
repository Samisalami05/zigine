const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const glfw_dep = b.dependency("glfw_zig", .{
        .target = target,
        .optimize = optimize,
    });


    const glad_dep = b.dependency("zig_glad", .{
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("opengl_zig", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    mod.link_libc = true;

    mod.addCSourceFile(.{ .file = b.path("src/stb_image.c") });
    mod.addIncludePath(b.path("src"));


    mod.linkLibrary(glfw_dep.artifact("glfw"));
    mod.linkLibrary(glad_dep.artifact("glad"));

    const exe = b.addExecutable(.{
        .name = "opengl_zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "opengl_zig", .module = mod },
            },
        }),
    });

    exe.root_module.linkLibrary(glfw_dep.artifact("glfw"));
    exe.root_module.linkLibrary(glad_dep.artifact("glad"));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
