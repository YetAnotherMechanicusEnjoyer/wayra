const std = @import("std");

pub fn render_dir(io: std.Io, allocator: std.mem.Allocator, dir_path: []const u8, req_path: []const u8) ![]const u8 {
    var list: std.ArrayListUnmanaged(u8) = .empty;

    const header = try std.fmt.allocPrint(allocator,
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head>
        \\    <meta charset="UTF-8">
        \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
        \\    <title>Index of {s}</title>
        \\    <style>
        \\        :root {{ --bg: #0f172a; --text: #f8fafc; --accent: #38bdf8; --card: #1e293b; --border: #334155; }}
        \\        @media (prefers-color-scheme: light) {{
        \\            :root {{ --bg: #f8fafc; --text: #0f172a; --accent: #0284c7; --card: #ffffff; --border: #e2e8f0; }}
        \\        }}
        \\        body {{ font-family: system-ui, -apple-system, sans-serif; margin: 0; padding: 2rem; background: var(--bg); color: var(--text); }}
        \\        .container {{ max-width: 800px; margin: 0 auto; }}
        \\        h1 {{ font-size: 1.5rem; margin-bottom: 1.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; }}
        \\        ul {{ list-style: none; padding: 0; }}
        \\        li {{ margin-bottom: 0.5rem; background: var(--card); border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }}
        \\        a {{ display: flex; align-items: center; padding: 0.75rem 1rem; text-decoration: none; color: var(--text); transition: background 0.15s; }}
        \\        a:hover {{ background: var(--accent); color: white; }}
        \\        .icon {{ font-size: 1.2rem; margin-right: 0.75rem; }}
        \\        .name {{ flex-grow: 1; font-family: ui-monospace, monospace; }}
        \\    </style>
        \\</head>
        \\<body>
        \\<div class="container">
        \\    <h1>Index of {s}</h1>
        \\    <ul>
    , .{ req_path, req_path });
    defer allocator.free(header);
    try list.appendSlice(allocator, header);

    if (!std.mem.eql(u8, req_path, "/")) {
        try list.appendSlice(allocator,
            \\<li><a href="../"><span class="icon">🔙</span><span class="name">..</span></a></li>
        );
    }

    var dir = try std.Io.Dir.cwd().openDir(io, dir_path, .{ .iterate = true });
    defer dir.close(io);

    var iter = dir.iterate();
    while (try iter.next(io)) |entry| {
        const is_dir = entry.kind == .directory;
        const icon = if (is_dir) "📁" else "📄";
        const slash = if (is_dir) "/" else "";

        const item = try std.fmt.allocPrint(allocator, "<li><a href=\"{s}{s}\"><span class=\"icon\">{s}</span><span class=\"name\">{s}{s}</span></a></li>\n", .{ entry.name, slash, icon, entry.name, slash });
        defer allocator.free(item);
        try list.appendSlice(allocator, item);
    }

    try list.appendSlice(allocator,
        \\    </ul>
        \\</div>
        \\</body>
        \\</html>
    );

    return list.toOwnedSlice(allocator);
}
