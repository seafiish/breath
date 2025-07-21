const std = @import("std");
const allocator = std.heap.page_allocator;

fn useMetaflac(flag: []const u8, file: []const u8) !void {
    var child = std.process.Child.init(&[_][]const u8{
        "metaflac", flag, file,
    }, allocator);
    try child.spawn();
    _ = try child.wait();
}

fn returnTag(tag: []const u8, file: []const u8) ![]u8 {
    var flag_buf: [64]u8 = undefined;
    const flag = try std.fmt.bufPrint(&flag_buf, "--show-tag={s}", .{tag});

    var child = std.process.Child.init(&[_][]const u8{
        "metaflac", flag, file,
    }, allocator);

    child.stdout_behavior = .Pipe;
    try child.spawn();

    // trim off the prefix "TAGNAME=" and trailing newline that metaflac outputs with --show-tag
    const reader = child.stdout.?.reader();
    var stdout = try reader.readAllAlloc(allocator, 4096);

    const prefix = try std.fmt.allocPrint(allocator, "{s}=", .{tag});
    defer allocator.free(prefix);

    if (std.mem.startsWith(u8, stdout, prefix)) {
        stdout = stdout[prefix.len..];
    }

    while (stdout.len > 0 and (stdout[stdout.len - 1] == '\n' or stdout[stdout.len - 1] == '\r')) {
        stdout = stdout[0 .. stdout.len - 1];
    }

    return stdout;
}

fn setTag(tag: []const u8, value: []u8, file: []const u8) !void {
    const needed_len = "--set-tag=".len + tag.len + 1 + value.len; // +1 for '='
    const buf = try allocator.alloc(u8, needed_len);
    defer allocator.free(buf);

    const flag = try std.fmt.bufPrint(buf, "--set-tag={s}={s}", .{ tag, value });

    var child = std.process.Child.init(&[_][]const u8{
        "metaflac", flag, file,
    }, allocator);

    try child.spawn();
    _ = try child.wait();
}

pub fn main() !void {
    var dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |file| {
        const path = file.path;
        if (file.kind != .file) continue;
        if (!std.mem.endsWith(u8, file.basename, ".flac")) continue;

        if ((try returnTag("UNSYNCEDLYRICS", path)).len != 0) {
            if ((try returnTag("LYRICS", path)).len == 0) {
                try setTag("LYRICS", try returnTag("UNSYNCEDLYRICS", path), path);
                std.debug.print("added LYRICS tag to {s}\n", .{path});
            }
            try useMetaflac("--remove-tag=UNSYNCEDLYRICS", path);
            std.debug.print("removed UNSYNCEDLYRICS tag from {s}\n", .{path});
        }
        if ((try returnTag("ALBUM", path)).len == 0) {
            try setTag("ALBUM", try returnTag("TITLE", path), path);
            std.debug.print("added ALBUM tag to {s}\n", .{path});
        }
        if ((try returnTag("ALBUMARTIST", path)).len == 0) {
            try setTag("ALBUMARTIST", try returnTag("ARTIST", path), path);
            std.debug.print("added ALBUMARTIST tag to {s}\n", .{path});
        }
    }
}
