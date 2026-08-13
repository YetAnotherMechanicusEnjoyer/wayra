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
        \\        svg {{ width: 30px; margin-right: 5px; }}
        \\        li {{ margin-bottom: 0.5rem; background: var(--card); border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }}
        \\        a {{ display: flex; align-items: center; padding: 0.75rem 1rem; text-decoration: none; color: var(--text); transition: background 0.15s; }}
        \\        a:hover {{ background: var(--accent); color: white; }}
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
            \\<li><a href="../">
            \\  <svg viewBox="0 0 24.00 24.00" fill="#f7c67f" xmlns="http://www.w3.org/2000/svg">
            \\      <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            \\      <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
            \\      <g id="SVGRepo_iconCarrier">
            \\          <path d="M9 13H15M9 13L11 15M9 13L11 11M12.0627 6.06274L11.9373 5.93726C11.5914 5.59135 11.4184 5.4184 11.2166 5.29472C11.0376 5.18506 10.8425 5.10425 10.6385 5.05526C10.4083 5 10.1637 5 9.67452 5H6.2C5.0799 5 4.51984 5 4.09202 5.21799C3.71569 5.40973 3.40973 5.71569 3.21799 6.09202C3 6.51984 3 7.07989 3 8.2V15.8C3 16.9201 3 17.4802 3.21799 17.908C3.40973 18.2843 3.71569 18.5903 4.09202 18.782C4.51984 19 5.07989 19 6.2 19H17.8C18.9201 19 19.4802 19 19.908 18.782C20.2843 18.5903 20.5903 18.2843 20.782 17.908C21 17.4802 21 16.9201 21 15.8V10.2C21 9.0799 21 8.51984 20.782 8.09202C20.5903 7.71569 20.2843 7.40973 19.908 7.21799C19.4802 7 18.9201 7 17.8 7H14.3255C13.8363 7 13.5917 7 13.3615 6.94474C13.1575 6.89575 12.9624 6.81494 12.7834 6.70528C12.5816 6.5816 12.4086 6.40865 12.0627 6.06274Z" stroke="#f7c67f" stroke-width="1.08" stroke-linecap="round" stroke-linejoin="round"></path>
            \\      </g>
            \\  </svg>
            \\  <span class="name">..</span>
            \\</a></li>
        );
    }

    var dir = try std.Io.Dir.cwd().openDir(io, dir_path, .{ .iterate = true });
    defer dir.close(io);

    var iter = dir.iterate();
    while (try iter.next(io)) |entry| {
        const is_dir = entry.kind == .directory;
        const icon = if (is_dir)
            \\<svg viewBox="0 0 24 24" fill="#f7c67f" xmlns="http://www.w3.org/2000/svg">
            \\  <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            \\  <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
            \\  <g id="SVGRepo_iconCarrier">
            \\      <path
            \\          d="M3 8.2C3 7.07989 3 6.51984 3.21799 6.09202C3.40973 5.71569 3.71569 5.40973 4.09202 5.21799C4.51984 5 5.0799 5 6.2 5H9.67452C10.1637 5 10.4083 5 10.6385 5.05526C10.8425 5.10425 11.0376 5.18506 11.2166 5.29472C11.4184 5.4184 11.5914 5.59135 11.9373 5.93726L12.0627 6.06274C12.4086 6.40865 12.5816 6.5816 12.7834 6.70528C12.9624 6.81494 13.1575 6.89575 13.3615 6.94474C13.5917 7 13.8363 7 14.3255 7H17.8C18.9201 7 19.4802 7 19.908 7.21799C20.2843 7.40973 20.5903 7.71569 20.782 8.09202C21 8.51984 21 9.0799 21 10.2V15.8C21 16.9201 21 17.4802 20.782 17.908C20.5903 18.2843 20.2843 18.5903 19.908 18.782C19.4802 19 18.9201 19 17.8 19H6.2C5.07989 19 4.51984 19 4.09202 18.782C3.71569 18.5903 3.40973 18.2843 3.21799 17.908C3 17.4802 3 16.9201 3 15.8V8.2Z"
            \\          stroke="#f7c67f" stroke-width="1.08" stroke-linecap="round" stroke-linejoin="round">
            \\      </path>
            \\  </g>
            \\</svg>
        else
            get_icon(entry.name);
        const slash = if (is_dir) "/" else "";

        const item = try std.fmt.allocPrint(allocator, "<li><a href=\"{s}{s}\">{s}<span class=\"name\">{s}{s}</span></a></li>\n", .{ entry.name, slash, icon, entry.name, slash });
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

fn get_icon(path: []const u8) []const u8 {
    const ext = std.fs.path.extension(path);

    if (std.ascii.eqlIgnoreCase(ext, ".png") or std.ascii.eqlIgnoreCase(ext, ".svg") or
        std.ascii.eqlIgnoreCase(ext, ".jpg") or std.ascii.eqlIgnoreCase(ext, ".jpeg") or
        std.ascii.eqlIgnoreCase(ext, ".gif")) return
    \\<svg fill="#2dcc9f" xmlns="http://www.w3.org/2000/svg" viewBox="-5.2 -5.2 62.40 62.40" enable-background="new 0 0 52 52" xml:space="preserve" stroke="#25cfdc" stroke-width="0.0005200000000000001" transform="rotate(0)">
    \\  <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
    \\  <g id="SVGRepo_iconCarrier">
    \\      <path d="M50,10c0-2.2-1.8-4-4-4H6c-2.2,0-4,1.8-4,4v32c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V10z M39.6,38h-29 c-1.2,0-1.9-1.3-1.3-2.3l8.8-15.3c0.4-0.7,1.3-0.7,1.7,0l5.3,9.1c0.4,0.6,1.3,0.7,1.7,0.1l4.3-6.2c0.4-0.6,1.3-0.6,1.7,0L40.7,36 C41.3,36.9,40.7,38,39.6,38z M37,20c-2.2,0-4-1.8-4-4s1.8-4,4-4s4,1.8,4,4S39.2,20,37,20z"></path>
    \\  </g>
    \\</svg>
    ;

    return
    \\<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    \\  <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
    \\  <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
    \\  <g id="SVGRepo_iconCarrier">
    \\      <path
    \\          d="M9 17H15M9 13H15M9 9H10M13 3H8.2C7.0799 3 6.51984 3 6.09202 3.21799C5.71569 3.40973 5.40973 3.71569 5.21799 4.09202C5 4.51984 5 5.0799 5 6.2V17.8C5 18.9201 5 19.4802 5.21799 19.908C5.40973 20.2843 5.71569 20.5903 6.09202 20.782C6.51984 21 7.0799 21 8.2 21H15.8C16.9201 21 17.4802 21 17.908 20.782C18.2843 20.5903 18.5903 20.2843 18.782 19.908C19 19.4802 19 18.9201 19 17.8V9M13 3L19 9M13 3V7.4C13 7.96005 13 8.24008 13.109 8.45399C13.2049 8.64215 13.3578 8.79513 13.546 8.89101C13.7599 9 14.0399 9 14.6 9H19"
    \\          stroke="#FFF" stroke-width="1.056" stroke-linecap="round" stroke-linejoin="round">
    \\      </path>
    \\  </g>
    \\</svg>
    ;
}
