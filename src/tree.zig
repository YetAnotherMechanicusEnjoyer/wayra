const std = @import("std");

pub const Tree = struct {
    pub fn build(io: std.Io, allocator: std.mem.Allocator, root_path: []const u8, list: *std.ArrayListUnmanaged(u8)) !void {
        try list.appendSlice(allocator, ".\n");
        try walk(io, allocator, root_path, "", list);
    }

    const Entry = struct {
        name: []const u8,
        is_dir: bool,
    };

    fn checkIsDir(io: std.Io, path: []const u8, kind: std.Io.File.Kind) bool {
        if (kind == .directory) return true;
        if (kind == .sym_link) {
            var resolved_buf: [std.fs.max_path_bytes]u8 = undefined;
            if (std.Io.Dir.cwd().realPathFile(io, path, &resolved_buf)) |resolved_len| {
                const resolved_path = resolved_buf[0..resolved_len];
                if (std.Io.Dir.cwd().statFile(io, resolved_path, .{})) |resolved_stat| {
                    return resolved_stat.kind == .directory;
                } else |_| {
                    return false;
                }
            } else |_| {
                return false;
            }
        }
        return false;
    }

    fn less_than(_: void, a: Entry, b: Entry) bool {
        if (a.is_dir and !b.is_dir) return true;
        if (!a.is_dir and b.is_dir) return false;
        return std.mem.order(u8, a.name, b.name) == .lt;
    }

    fn walk(io: std.Io, allocator: std.mem.Allocator, current_path: []const u8, prefix: []const u8, list: *std.ArrayListUnmanaged(u8)) !void {
        var dir = std.Io.Dir.cwd().openDir(io, current_path, .{ .iterate = true }) catch return;
        defer dir.close(io);

        var entries: std.ArrayList(Entry) = .empty;
        defer {
            for (entries.items) |entry| allocator.free(entry.name);
            entries.deinit(allocator);
        }

        var it = dir.iterate();
        while (try it.next(io)) |entry| {
            if (std.mem.startsWith(u8, entry.name, ".")) continue;
            const entry_path = try std.fs.path.join(allocator, &.{ current_path, entry.name });
            defer allocator.free(entry_path);

            const is_directory = checkIsDir(io, entry_path, entry.kind);

            try entries.append(allocator, .{
                .name = try allocator.dupe(u8, entry.name),
                .is_dir = is_directory,
            });
        }

        std.mem.sort(Entry, entries.items, {}, less_than);

        for (entries.items, 0..) |entry, i| {
            const is_last = (i == entries.items.len - 1);
            const branch = if (is_last) "└── " else "├── ";
            const slash = if (entry.is_dir) "/" else "";

            const s = try std.fmt.allocPrint(allocator, "{s}{s}{s}{s}\n", .{ prefix, branch, entry.name, slash });
            defer allocator.free(s);

            try list.appendSlice(allocator, s);

            if (entry.is_dir) {
                const next_prefix_add = if (is_last) "    " else "│   ";
                const next_prefix = try std.fmt.allocPrint(allocator, "{s}{s}", .{ prefix, next_prefix_add });
                defer allocator.free(next_prefix);

                const next_path = try std.fs.path.join(allocator, &.{ current_path, entry.name });
                defer allocator.free(next_path);

                try walk(io, allocator, next_path, next_prefix, list);
            }
        }
    }
};
