const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const zmath_dep = b.dependency("zmath", .{});
    const zstbi_dep = b.dependency("zstbi", .{});

    const ge = b.addModule("game-engine", .{
        .root_source_file = .{ .path = "src/root.zig" },
    });
    ge.addImport("zmath", zmath_dep.module("root"));
    ge.addImport("zstbi", zstbi_dep.module("root"));
    ge.addAnonymousImport("gl", .{
        .root_source_file = .{ .path = "ge/gl4v6.zig" },
    });
    ge.addLibraryPath(.{ .path = "lib" });
    ge.addIncludePath(.{ .path = "include" });

    const lib = b.addStaticLibrary(.{
        .name = "game-engine",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("zmath", zmath_dep.module("root"));
    lib.root_module.addImport("zstbi", zstbi_dep.module("root"));
    lib.root_module.addAnonymousImport("gl", .{
        .root_source_file = .{ .path = "lib/gl4v6.zig" },
    });
    lib.addLibraryPath(.{ .path = "lib" });
    lib.addIncludePath(.{ .path = "include" });
    lib.linkSystemLibrary("glfw3");
    lib.linkSystemLibrary("c");
    lib.linkSystemLibrary("user32");
    lib.linkSystemLibrary("gdi32");
    lib.linkSystemLibrary("shell32");
    lib.linkLibC();

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
