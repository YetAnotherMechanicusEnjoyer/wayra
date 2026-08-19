const std = @import("std");

const bc = @import("ui/breadcrumbs.zig");
const head = @import("ui/header.zig");
const icons = @import("ui/icons.zig");
const ls = @import("ui/list.zig");
const script = @import("ui/script.zig");

pub fn render_dir(io: std.Io, allocator: std.mem.Allocator, dir_path: []const u8, req_path: []const u8) ![]const u8 {
    var list: std.ArrayListUnmanaged(u8) = .empty;

    const breadcrumbs = try bc.render_breadcrumbs(allocator, req_path);
    defer allocator.free(breadcrumbs);

    try list.appendSlice(allocator,
        \\<!DOCTYPE html>
        \\<html lang="en">
    );

    try head.render_header(allocator, &list);

    try list.appendSlice(allocator,
        \\<body>
        \\<div class="container">
        \\    <header>
        \\        <div class="top-bar">
        \\            <div class="brand">
        \\                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
        \\                <span>Wayra Explorer</span>
        \\            </div>
        \\            <div class="count-badge" id="item-count">0 items</div>
        \\        </div>
    );

    try list.appendSlice(allocator, breadcrumbs);

    try list.appendSlice(allocator,
        \\    </header>
        \\        <div class="header-actions">
        \\          <button id="toggle-list-btn" class="btn">
        \\            Auto-Render index.html
        \\          </button>
        \\        </div>
        \\    <div class="search-box">
        \\        <svg class="search-icon" viewBox="0 0 24 24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        \\        <input type="text" id="search-input" placeholder="Filter files and directories..." autocomplete="off">
        \\    </div>
        \\    <ul id="file-list">
    );

    if (!std.mem.eql(u8, req_path, "/") and !std.mem.startsWith(u8, req_path, "/?")) {
        const parent_icon = icons.get_parent_dir_icon();
        try list.appendSlice(allocator,
            \\<li data-parent="true">
            \\  <a href="../" class="item-link">
            \\    <div class="icon-wrapper">
        );
        try list.appendSlice(allocator, parent_icon);
        try list.appendSlice(allocator,
            \\    </div>
            \\    <span class="name">..</span>
            \\  </a>
            \\</li>
            \\
        );
    }

    try ls.render_items(io, allocator, dir_path, &list);

    try list.appendSlice(allocator,
        \\    </ul>
        \\</div>
        \\
        \\<div id="preview-modal">
        \\    <div class="modal-content">
        \\        <div id="preview-header">
        \\            <span id="preview-title"></span>
        \\            <div class="modal-actions">
        \\                <button id="copy-btn" class="btn" style="display:none;">Copy</button>
        \\                <a id="dl-modal-btn" href="#" download class="btn">Download</a>
        \\                <button id="toggle-render-btn" class="btn" style="display:none;">Render</button>
        \\                <button id="close-modal" class="btn">&times;</button>
        \\            </div>
        \\        </div>
        \\        <div id="preview-body"></div>
        \\    </div>
        \\</div>
        \\
    );

    try script.render_script(allocator, &list);

    try list.appendSlice(allocator,
        \\</body>
        \\</html>
    );

    return list.toOwnedSlice(allocator);
}
