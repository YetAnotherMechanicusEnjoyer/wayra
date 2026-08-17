const std = @import("std");

pub const Tree = struct {
    pub fn build(io: std.Io, allocator: std.mem.Allocator, root_path: []const u8, list: *std.ArrayListUnmanaged(u8)) !void {
        try list.appendSlice(allocator, ".\n");
        try walk(io, allocator, root_path, "", list);
    }

    const Entry = struct {
        name: []const u8,
        kind: std.Io.File.Kind,
    };

    fn is_dir(e: Entry) bool {
        return e.kind == .directory or e.kind == .sym_link;
    }

    fn less_than(_: void, a: Entry, b: Entry) bool {
        if (is_dir(a) and !is_dir(b)) return true;
        if (!is_dir(a) and is_dir(b)) return false;
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

            try entries.append(allocator, .{
                .name = try allocator.dupe(u8, entry.name),
                .kind = entry.kind,
            });
        }

        std.mem.sort(Entry, entries.items, {}, less_than);

        for (entries.items, 0..) |entry, i| {
            const is_last = (i == entries.items.len - 1);
            const branch = if (is_last) "└── " else "├── ";
            const slash = if (is_dir(entry)) "/" else "";

            const s = try std.fmt.allocPrint(allocator, "{s}{s}{s}{s}\n", .{ prefix, branch, entry.name, slash });
            defer allocator.free(s);

            try list.appendSlice(allocator, s);

            if (is_dir(entry)) {
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
