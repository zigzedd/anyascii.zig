const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	// Anyascii zig module.
	const anyascii = b.addModule("anyascii", .{
		.root_source_file = b.path("src/lib.zig"),
		.target = target,
		.optimize = optimize,
	});
	anyascii.link_libc = true;
	anyascii.addIncludePath(b.path("anyascii"));
	anyascii.addCSourceFile(.{
		.file = b.path("anyascii/anyascii.c"),
	});

	// Library unit tests.
	const lib_unit_tests = b.addTest(.{
		.root_source_file = b.path("src/lib.zig"),
		.target = target,
		.optimize = optimize,
	});
	lib_unit_tests.linkLibC();
	lib_unit_tests.addIncludePath(b.path("anyascii"));
	lib_unit_tests.addCSourceFile(.{
		.file = b.path("anyascii/anyascii.c"),
	});
	const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

	const test_step = b.step("test", "Run unit tests");
	test_step.dependOn(&run_lib_unit_tests.step);
}
