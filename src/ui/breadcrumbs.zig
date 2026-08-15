const std = @import("std");

pub fn render_breadcrumbs(allocator: std.mem.Allocator, req_path: []const u8) ![]const u8 {
    var buf: std.ArrayListUnmanaged(u8) = .empty;
    try buf.appendSlice(allocator, "<nav class=\"breadcrumbs\"><a href=\"/\" class=\"crumb\">root</a>");

    var path = std.mem.tokenizeScalar(u8, req_path, '?');
    var iter = std.mem.tokenizeScalar(u8, path.next().?, '/');
    var path_acc: std.ArrayListUnmanaged(u8) = .empty;
    defer path_acc.deinit(allocator);

    while (iter.next()) |part| {
        try path_acc.append(allocator, '/');
        try path_acc.appendSlice(allocator, part);

        const is_last = iter.index >= req_path.len;
        try buf.appendSlice(allocator, "<span class=\"sep\">/</span>");

        if (is_last) {
            const item = try std.fmt.allocPrint(allocator, "<span class=\"crumb current\">{s}</span>", .{part});
            defer allocator.free(item);
            try buf.appendSlice(allocator, item);
        } else {
            const item = try std.fmt.allocPrint(allocator, "<a href=\"{s}/\" class=\"crumb\">{s}</a>", .{ path_acc.items, part });
            defer allocator.free(item);
            try buf.appendSlice(allocator, item);
        }
    }

    try buf.appendSlice(allocator, "</nav>");
    return buf.toOwnedSlice(allocator);
}
