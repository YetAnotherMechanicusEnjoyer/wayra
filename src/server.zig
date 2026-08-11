const std = @import("std");

const String = @import("string").String;

const handler = @import("handler.zig");

pub const Server = @This();

allocator: std.mem.Allocator,
host: []const u8,
port: u16,
root_dir: []const u8,

pub fn run(self: *Server, io: std.Io, err_ctx: *String) !void {
    const address = try std.Io.net.IpAddress.parse(self.host, self.port);
    var server = address.listen(io, .{ .reuse_address = true }) catch |e| {
        try err_ctx.push("listening to address");
        return e;
    };
    defer server.deinit(io);

    std.log.info("Serving HTTP on {s} port {d}...", .{ self.host, self.port });
    std.log.info("Root directory: \"{s}\"", .{self.root_dir});
    if (std.mem.indexOf(u8, self.host, "::") != null) {
        std.log.info("URL: http://[{s}]:{d}/", .{ self.host, self.port });
    } else {
        std.log.info("URL: http://{s}:{d}/", .{ self.host, self.port });
    }

    while (true) {
        const conn = server.accept(io) catch |e| {
            std.log.err("Error accepting connection: {}", .{e});
            continue;
        };

        const thread = std.Thread.spawn(.{}, handler.handle_connection, .{ io, self.allocator, conn, self.root_dir }) catch |e| {
            std.log.err("Error creating thread: {}", .{e});
            conn.close(io);
            continue;
        };

        thread.detach();
    }
}
