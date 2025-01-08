# anyascii.zig

This repository allows to use anyascii C implementation from zig, with a helper function `utf8ToAscii` to easily convert any UTF-8 encoded string in an ASCII-only string.

Current version of anyascii: `2023-08-01`.

## How to use

### `anyascii`

```zig
const std = @import("std");
const anyascii = @import("anyascii").anyascii;

// A single UTF-8 codepoint to its ASCII equivalent.
const ascii = try anyascii(allocator, try std.unicode.utf8Decode("Φ"));
defer allocator.free(ascii);
std.debug.print("{s}", .{ascii}); // Output: "F".
```

### `utf8ToAscii`

```zig
const std = @import("std");
const utf8ToAscii = @import("anyascii").utf8ToAscii;

// A full string of UTF-8 characters to ASCII characters.
const ascii = try utf8ToAscii(allocator, "Blöße");
defer allocator.free(ascii);
std.debug.print("{s}", .{ascii}); // Output: "Blosse".
```

### Install

In your project directory:

```shell
zig fetch --save https://code.zeptotech.net/zedd/anyascii.zig/archive/v1.1.0.tar.gz
```

In `build.zig`:

```zig
// Add anyascii.zig dependency.
const anyascii = b.dependency("anyascii.zig", .{
	.target = target,
	.optimize = optimize,
});
exe.root_module.addImport("anyascii", anyascii.module("anyascii"));
```

## What is anyascii?

Taken from [official _anyascii_ description](https://github.com/anyascii/anyascii/tree/master#description).

AnyAscii provides ASCII-only replacement strings for practically all Unicode characters. Text is converted character-by-character without considering the context. The mappings for each script are based on popular existing romanization systems. Symbolic characters are converted based on their meaning or appearance. All ASCII characters in the input are left unchanged, every other character is replaced with printable ASCII characters.
