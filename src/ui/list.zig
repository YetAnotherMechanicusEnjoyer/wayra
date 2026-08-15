const std = @import("std");

const icons = @import("icons.zig");

pub fn render_items(io: std.Io, allocator: std.mem.Allocator, dir_path: []const u8, list: *std.ArrayListUnmanaged(u8)) !void {
    var dir = try std.Io.Dir.cwd().openDir(io, dir_path, .{ .iterate = true });
    defer dir.close(io);

    var iter = dir.iterate();
    while (try iter.next(io)) |entry| {
        const is_dir = entry.kind == .directory;
        const icon = icons.get_icon(entry.name, is_dir);
        const ext_label = if (is_dir) "" else get_extension_label(entry.name);

        if (is_dir) {
            const item = try std.fmt.allocPrint(allocator,
                \\<li>
                \\  <a href="{s}/" class="item-link" data-type="dir">
                \\    <div class="icon-wrapper">{s}</div>
                \\    <span class="name">{s}/</span>
                \\  </a>
                \\</li>
                \\
            , .{ entry.name, icon, entry.name });
            defer allocator.free(item);
            try list.appendSlice(allocator, item);
        } else {
            const item = try std.fmt.allocPrint(allocator,
                \\<li>
                \\  <a href="{s}" class="item-link" data-type="file">
                \\    <div class="icon-wrapper">{s}</div>
                \\    <span class="name">{s}</span>
                \\    <span class="badge">{s}</span>
                \\  </a>
                \\  <a href="{s}" download="{s}" class="dl-btn" title="Download">
                \\    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                \\  </a>
                \\</li>
                \\
            , .{ entry.name, icon, entry.name, ext_label, entry.name, entry.name });
            defer allocator.free(item);
            try list.appendSlice(allocator, item);
        }
    }
}

fn get_extension_label(filename: []const u8) []const u8 {
    const ext = std.fs.path.extension(filename);
    if (ext.len > 1) return ext[1..];
    return "FILE";
}
