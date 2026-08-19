const std = @import("std");

const Server = std.http.Server;

const mime = @import("mime.zig");
const tree = @import("tree.zig");
const ui = @import("ui.zig");
const utils = @import("utils.zig");

pub fn handle_connection(io: std.Io, allocator: std.mem.Allocator, conn: std.Io.net.Stream, root_dir: []const u8) void {
    defer conn.close(io);

    var read_buf: [8196]u8 = undefined;
    var write_buf: [8196]u8 = undefined;

    var reader = conn.reader(io, &read_buf);
    var writer = conn.writer(io, &write_buf);

    var server = Server.init(&reader.interface, &writer.interface);

    while (true) {
        var req = server.receiveHead() catch |e| {
            if (e == std.http.Reader.HeadError.HttpConnectionClosing) break;
            std.log.err("Error receiving HTTP request: {}", .{e});
            break;
        };

        handle_request(io, allocator, conn.socket.address, &req, &writer.interface, root_dir) catch |e| {
            std.log.err("Error handling request: {}", .{e});
            break;
        };

        if (!req.head.keep_alive) break;
    }
}

fn handle_request(io: std.Io, allocator: std.mem.Allocator, addr: std.Io.net.IpAddress, req: *Server.Request, writer: *std.Io.Writer, root_dir: []const u8) !void {
    const target = req.head.target;

    if (std.mem.indexOf(u8, target, "..") != null) {
        log_request(io, addr, req, .bad_request, "Bad Request");
        try send_error(req, .bad_request, "400 Bad Request");
        return;
    }

    const render = std.mem.indexOf(u8, target, "?render") != null;
    const download = std.mem.indexOf(u8, target, "?download") != null;
    const curl_client = utils.is_curl(req);

    var clean_path = target;
    if (std.mem.indexOf(u8, clean_path, "?")) |idx| clean_path = clean_path[0..idx];
    if (clean_path.len > 0 and clean_path[0] == '/') clean_path = clean_path[1..];
    if (clean_path.len == 0) clean_path = ".";

    const real_path = try std.fs.path.join(allocator, &.{ root_dir, clean_path });
    defer allocator.free(real_path);

    const stat = std.Io.Dir.cwd().statFile(io, real_path, .{}) catch |e| {
        if (e == std.Io.Dir.StatFileError.FileNotFound) {
            log_request(io, addr, req, .not_found, "Not Found");
            try send_error(req, .not_found, "404 Not Found");
        } else {
            log_request(io, addr, req, .internal_server_error, "Internal Server Error");
            try send_error(req, .internal_server_error, "500 Internal Server Error");
        }
        return;
    };

    const target_stat = utils.get_stat(io, real_path, stat);

    if (target_stat.kind == .directory) {
        if (curl_client) {
            log_request(io, addr, req, .ok, null);
            try serve_tree_listing(io, allocator, req, real_path);
            return;
        }
        if (!render) {
            log_request(io, addr, req, .ok, null);
            try serve_dir_listing(io, allocator, req, real_path, target);
        } else if (download) {
            log_request(io, addr, req, .ok, null);
            try serve_dir_download(io, allocator, req, writer, real_path);
            return;
        } else {
            const index_path = try std.fs.path.join(allocator, &.{ real_path, "index.html" });
            defer allocator.free(index_path);

            if (std.Io.Dir.cwd().statFile(io, index_path, .{})) |index_stat| {
                log_request(io, addr, req, .ok, null);
                try serve_file(io, req, writer, index_path, index_stat.size);
            } else |_| {
                log_request(io, addr, req, .ok, null);
                try serve_dir_listing(io, allocator, req, real_path, target);
            }
        }
    } else {
        log_request(io, addr, req, .ok, null);
        try serve_file(io, req, writer, real_path, target_stat.size);
    }
}

fn serve_tree_listing(io: std.Io, allocator: std.mem.Allocator, req: *Server.Request, real_path: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_alloc = arena.allocator();

    var list: std.ArrayListUnmanaged(u8) = .empty;
    defer list.deinit(arena_alloc);

    try tree.Tree.build(io, arena_alloc, real_path, &list);

    try req.respond(list.items, .{
        .status = .ok,
        .extra_headers = &.{
            .{ .name = "Content-Type", .value = "text/plain; charset=utf-8" },
        },
    });
}

fn serve_dir_download(io: std.Io, allocator: std.mem.Allocator, req: *Server.Request, writer: *std.Io.Writer, real_path: []const u8) !void {
    var target_dir = std.fs.path.basename(real_path);
    const parent_dir = std.fs.path.dirname(real_path) orelse ".";

    var filename_base = target_dir;
    if (target_dir.len == 0 or std.mem.eql(u8, target_dir, ".")) {
        filename_base = "archive";
        target_dir = ".";
    }

    var child = try std.process.spawn(io, .{ .argv = &.{ "tar", "-czhf", "-", "-C", parent_dir, target_dir }, .stdout = .pipe, .stderr = .ignore });
    defer _ = child.wait(io) catch {};

    const filename = try std.fmt.allocPrint(allocator, "{s}.tar.gz", .{filename_base});
    defer allocator.free(filename);

    try writer.print("HTTP/1.1 200 OK\r\n", .{});
    try writer.print("Content-Type: application/gzip\r\n", .{});
    try writer.print("Content-Disposition: attachment; filename=\"{s}\"\r\n", .{filename});
    try writer.print("Transfer-Encoding: chunked\r\n", .{});

    if (req.head.keep_alive) {
        try writer.print("Connection: keep-alive\r\n\r\n", .{});
    } else {
        try writer.print("Connection: close\r\n\r\n", .{});
    }

    var stdout_buf: [4096]u8 = undefined;
    var stdout = child.stdout.?.reader(io, &stdout_buf);

    while (true) {
        var buf: [8192]u8 = undefined;

        const bytes_read = stdout.interface.readSliceShort(&buf) catch break;
        if (bytes_read == 0) break;

        writer.print("{x}\r\n", .{bytes_read}) catch break;
        writer.writeAll(buf[0..bytes_read]) catch break;
        writer.print("\r\n", .{}) catch break;
    }

    writer.print("0\r\n\r\n", .{}) catch {};

    if (@hasDecl(@TypeOf(writer.*), "flush")) {
        writer.flush() catch {};
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

fn log_request(io: std.Io, address: std.Io.net.IpAddress, req: *Server.Request, status: std.http.Status, msg: ?[]const u8) void {
    const timestamp = std.Io.Clock.now(.real, io).toSeconds();
    const epoch_secs = std.time.epoch.EpochSeconds{ .secs = @intCast(timestamp) };
    const epoch_day = epoch_secs.getEpochDay();
    const epoch_year = epoch_day.calculateYearDay();
    const epoch_month = epoch_year.calculateMonthDay();
    const day_secs = epoch_secs.getDaySeconds();

    var buffer: [64]u8 = undefined;
    const address_str = utils.ipToString(address, &buffer) catch "";

    if (msg) |m| {
        std.log.info("{s} - [{d:0>2}/{d:0>2}/{d} {d:0>2}:{d:0>2}:{d:0>2}] code {d}, message {s}", .{
            address_str,
            epoch_month.day_index + 1,
            epoch_month.month.numeric(),
            epoch_year.year,
            day_secs.getHoursIntoDay(),
            day_secs.getMinutesIntoHour(),
            day_secs.getSecondsIntoMinute(),
            @intFromEnum(status),
            m,
        });
    }

    std.log.info("{s} - [{d:0>2}/{d:0>2}/{d} {d:0>2}:{d:0>2}:{d:0>2}] \"{s} {s} {s}\" {d}", .{
        address_str,
        epoch_month.day_index + 1,
        epoch_month.month.numeric(),
        epoch_year.year,
        day_secs.getHoursIntoDay(),
        day_secs.getMinutesIntoHour(),
        day_secs.getSecondsIntoMinute(),
        @tagName(req.head.method),
        req.head.target,
        @tagName(req.head.version),
        @intFromEnum(status),
    });
}
