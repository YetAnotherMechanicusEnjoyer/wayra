const std = @import("std");

const Server = std.http.Server;

const mime = @import("mime.zig");
const ui = @import("ui.zig");

pub fn handle_connection(io: std.Io, allocator: std.mem.Allocator, conn: std.Io.net.Stream, root_dir: []const u8) void {
    defer conn.close(io);

    var read_buf: [8196]u8 = undefined;
    var write_buf: [8196]u8 = undefined;

    var reader = conn.reader(io, &read_buf);
    var writer = conn.writer(io, &write_buf);

    var server = Server.init(&reader.interface, &writer.interface);

    while (true) {
        var req = server.receiveHead() catch |e| {
            std.log.err("Error receiving HTTP request: {}", .{e});
            break;
        };

        handle_request(io, allocator, &req, &writer.interface, root_dir) catch |e| {
            std.log.err("Error handling request: {}", .{e});
            break;
        };

        if (!req.head.keep_alive) break;
    }
}

fn handle_request(io: std.Io, allocator: std.mem.Allocator, req: *Server.Request, writer: *std.Io.Writer, root_dir: []const u8) !void {
    const target = req.head.target;

    if (std.mem.indexOf(u8, target, "..") != null) {
        try send_error(req, .bad_request, "400 Bad Request");
        return;
    }

    var clean_path = target;
    if (std.mem.indexOf(u8, clean_path, "?")) |idx| clean_path = clean_path[0..idx];
    if (clean_path.len > 0 and clean_path[0] == '/') clean_path = clean_path[1..];
    if (clean_path.len == 0) clean_path = ".";

    const real_path = try std.fs.path.join(allocator, &.{ root_dir, clean_path });
    defer allocator.free(real_path);

    const stat = std.Io.Dir.cwd().statFile(io, real_path, .{}) catch |e| {
        if (e == std.Io.Dir.StatFileError.FileNotFound) {
            try send_error(req, .not_found, "404 Not Found");
        } else {
            try send_error(req, .internal_server_error, "500 Internal Server Error");
        }
        return;
    };

    if (stat.kind == .directory) {
        const index_path = try std.fs.path.join(allocator, &.{ real_path, "index.html" });
        defer allocator.free(index_path);

        if (std.Io.Dir.cwd().statFile(io, index_path, .{})) |index_stat| {
            try serve_file(io, req, writer, index_path, index_stat.size);
        } else |_| {
            try serve_dir_listing(io, allocator, req, real_path, target);
        }
    } else {
        try serve_file(io, req, writer, real_path, stat.size);
    }
}

fn serve_file(io: std.Io, req: *Server.Request, writer: *std.Io.Writer, path: []const u8, size: u64) !void {
    var file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);

    const mime_type = mime.get_mime(path);

    try writer.print("HTTP/1.1 200 OK\r\n", .{});
    try writer.print("Content-Type: {s}\r\n", .{mime_type});
    try writer.print("Content-Length: {d}\r\n", .{size});
    if (req.head.keep_alive) {
        try writer.print("Connection: keep_alive\r\n\r\n", .{});
    } else {
        try writer.print("Connection: close\r\n\r\n", .{});
    }

    var file_buf: [4096]u8 = undefined;
    var reader = file.reader(io, &file_buf);

    while (true) {
        var buffer: [8192]u8 = undefined;
        const bytes_read = try reader.interface.readSliceShort(&buffer);
        if (bytes_read == 0) break;
        try writer.writeAll(&buffer);
    }
    try writer.flush();
}

fn serve_dir_listing(io: std.Io, allocator: std.mem.Allocator, req: *Server.Request, real_path: []const u8, req_path: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_alloc = arena.allocator();

    const html_content = try ui.render_dir(io, arena_alloc, real_path, req_path);

    try req.respond(html_content, .{
        .status = .ok,
        .extra_headers = &.{
            .{ .name = "Content-Type", .value = "text/html; charset=utf-8" },
        },
    });
}

fn send_error(req: *Server.Request, status: std.http.Status, msg: []const u8) !void {
    try req.respond(msg, .{ .status = status, .extra_headers = &.{
        .{ .name = "Content-Type", .value = "text/plain" },
    } });
}
