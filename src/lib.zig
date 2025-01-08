const std = @import("std");

const c = @cImport({
	@cInclude("anyascii.h");
});

/// Convert a unicode codepoint to its ascii equivalent.
pub fn anyascii(allocator: std.mem.Allocator, codepoint: u21) ![]u8 {
	// Call C anyascii function.
	var cChars: [*]u8 = undefined;
	const charsCount = c.anyascii(codepoint, @ptrCast(&cChars));

	// Convert the raw C pointer to a zig allocated result.
	const result = try allocator.alloc(u8, charsCount);
	for (0..charsCount) |i| {
		result[i] = cChars[i];
	}
	return result;
}

/// Convert a unicode codepoint to its ascii equivalent, in the provided writer.
pub fn anyasciiWrite(writer: std.io.AnyWriter, codepoint: u21) !void {
	// Call C anyascii function.
	var cChars: [*]u8 = undefined;
	const charsCount = c.anyascii(codepoint, @ptrCast(&cChars));

	// Write every byte from the raw C pointer.
	for (0..charsCount) |i| {
		try writer.writeByte(cChars[i]);
	}
}

/// Convert a given UTF-8 string to its ASCII equivalent using anyascii.
pub fn utf8ToAscii(allocator: std.mem.Allocator, str: []const u8) ![]u8 {
	// Get a UTF8 iterator.
	var iterator = (try std.unicode.Utf8View.init(str)).iterator();

	// Initialize a out string array list where ascii equivalents will be appended.
	var outStr = try std.ArrayList(u8).initCapacity(allocator, str.len | 15);
	defer outStr.deinit();

	// Get a writer to the array list.
	const writer = outStr.writer().any();

	// For each codepoint, convert it to ascii.
	while (iterator.nextCodepoint()) |codepoint| {
		try anyasciiWrite(writer, codepoint);
	}

	// Return the built full ascii equivalent.
	return outStr.toOwnedSlice();
}

test anyascii {
	try testAnyascii("a", "a");
	try testAnyascii("o", "ø");
	try testAnyascii("e", "ë");
	try testAnyascii("s", "ŝ");
	try testAnyascii("F", "Φ");
	try testAnyascii(":crown:", "👑");
}

/// Test the conversion of a given UTF-8 character to its ASCII equivalent.
fn testAnyascii(expectedAscii: []const u8, utf8str: []const u8) !void {
	const ascii = try anyascii(std.testing.allocator, try std.unicode.utf8Decode(utf8str));
	defer std.testing.allocator.free(ascii);
	try std.testing.expectEqualStrings(expectedAscii, ascii);
}

test utf8ToAscii {
	// These examples are taken from anyascii examples, see https://github.com/anyascii/anyascii/tree/master#examples

	try testUtf8ToAscii("a ", "à ");
	try testUtf8ToAscii("a", "à");
	try testUtf8ToAscii("Rene Francois Lacote", "René François Lacôte");
	try testUtf8ToAscii("Blosse", "Blöße");
	try testUtf8ToAscii("Tran Hung Dao", "Trần Hưng Đạo");
	try testUtf8ToAscii("Naeroy", "Nærøy");
	try testUtf8ToAscii("Feidippidis", "Φειδιππίδης");
	try testUtf8ToAscii("Dimitris Fotopoylos", "Δημήτρης Φωτόπουλος");
	try testUtf8ToAscii("Boris Nikolaevich El'tsin", "Борис Николаевич Ельцин");
	try testUtf8ToAscii("Volodimir Gorbulin", "Володимир Горбулін");
	try testUtf8ToAscii("T'rgovishche", "Търговище");
	try testUtf8ToAscii("ShenZhen", "深圳");
	try testUtf8ToAscii("ShenShuiBu", "深水埗");
	try testUtf8ToAscii("HwaSeongSi", "화성시");
	try testUtf8ToAscii("HuaChengShi", "華城市");
	try testUtf8ToAscii("saitama", "さいたま");
	try testUtf8ToAscii("QiYuXian", "埼玉県");
	try testUtf8ToAscii("debre zeyt", "ደብረ ዘይት");
	try testUtf8ToAscii("dek'emhare", "ደቀምሓረ");
	try testUtf8ToAscii("dmnhwr", "دمنهور");
	try testUtf8ToAscii("Abovyan", "Աբովյան");
	try testUtf8ToAscii("samt'redia", "სამტრედია");
	try testUtf8ToAscii("'vrhm hlvy frnkl", "אברהם הלוי פרנקל");
	try testUtf8ToAscii("+say x ag", "⠠⠎⠁⠽⠀⠭⠀⠁⠛");
	try testUtf8ToAscii("mymnsimh", "ময়মনসিংহ");
	try testUtf8ToAscii("thntln", "ထန်တလန်");
	try testUtf8ToAscii("porbmdr", "પોરબંદર");
	try testUtf8ToAscii("mhasmumd", "महासमुंद");
	try testUtf8ToAscii("bemgluru", "ಬೆಂಗಳೂರು");
	try testUtf8ToAscii("siemrab", "សៀមរាប");
	try testUtf8ToAscii("sahvannaekhd", "ສະຫວັນນະເຂດ");
	try testUtf8ToAscii("klmsseri", "കളമശ്ശേരി");
	try testUtf8ToAscii("gjpti", "ଗଜପତି");
	try testUtf8ToAscii("jlmdhr", "ਜਲੰਧਰ");
	try testUtf8ToAscii("rtnpur", "රත්නපුර");
	try testUtf8ToAscii("knniyakumri", "கன்னியாகுமரி");
	try testUtf8ToAscii("srikakulm", "శ్రీకాకుళం");
	try testUtf8ToAscii("sngkhla", "สงขลา");

	try testUtf8ToAscii(":crown: :palm_tree:", "👑 🌴");
	try testUtf8ToAscii("* # + 5 X", "☆ ♯ ♰ ⚄ ⛌");
	try testUtf8ToAscii("No M & A/S", "№ ℳ ⅋ ⅍");
}

/// Test the conversion of a given UTF-8 string to its ASCII equivalent.
fn testUtf8ToAscii(expectedAscii: []const u8, utf8str: []const u8) !void {
	const ascii = try utf8ToAscii(std.testing.allocator, utf8str);
	defer std.testing.allocator.free(ascii);
	try std.testing.expectEqualStrings(expectedAscii, ascii);
}
