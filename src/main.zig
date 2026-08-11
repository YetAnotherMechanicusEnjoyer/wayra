const std = @import("std");

const String = @import("string").String;

const APP_NAME: []const u8 = "wayra";
const DEFAULT_PORT: u16 = 8000;
const DEFAULT_DIR: []const u8 = ".";

const Error = error{
    BadUsage,
    InvalidPort,
    InvalidDir,
};

pub fn main(init: std.process.Init) !u8 {
    const io = init.io;
    const allocator = init.arena.allocator();

    var args = init.minimal.args.iterate();
    _ = args.skip();

    var err_ctx = String.init(allocator);
    defer err_ctx.deinit();

    parse_arguments(io, allocator, &args, &err_ctx) catch |err| {
        if (err == Error.BadUsage) print_usage(io);
        if (err_ctx.len() > 0) {
            std.log.err("Exited with error: {any}: {s}.", .{ err, err_ctx.content });
        } else std.log.err("Exited with error: {any}", .{err});
        return 1;
    };
    return 0;
}

fn parse_arguments(io: std.Io, allocator: std.mem.Allocator, args: *std.process.Args.Iterator, err_ctx: *String) !void {
    _ = allocator;

    var port = DEFAULT_PORT;
    var dir = DEFAULT_DIR;

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--port")) {
            if (args.next()) |p| {
                port = std.fmt.parseInt(u16, p, 10) catch {
                    try err_ctx.push(p);
                    return Error.InvalidPort;
                };
            } else {
                try err_ctx.push("expected one argument");
                return Error.InvalidPort;
            }
        } else if (std.mem.eql(u8, arg, "-d") or std.mem.eql(u8, arg, "--dir")) {
            if (args.next()) |d| {
                dir = d;
            } else {
                try err_ctx.push("expected one argument");
                return Error.InvalidDir;
            }
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            print_usage(io);
            return;
        } else return Error.BadUsage;
    }
}

fn print_usage(io: std.Io) void {
    var buffer: [1024]u8 = undefined;
    const stdout = std.Io.File.stdout();
    var writer = stdout.writer(io, &buffer);

    const dim = "\x1b[0;90m";
    const blue = "\x1b[1;94m";
    const green = "\x1b[0;1;92m";
    const bold = "\x1b[0;1m";
    const reset = "\x1b[0m";

    const to_print = .{
        .{ "{s}:: {s}Usage{s}:{s}\n", .{ dim, blue, dim, reset } },
        .{ "   {s}{s}{s} [OPTIONS]\n\n", .{ green, APP_NAME, reset } },
        .{ "{s}:: {s}Options{s}:{s}\n", .{ dim, blue, dim, reset } },
        .{ "   {s}-p, --port <port>{s}           Server port                {s}(default: {d}){s}\n", .{ bold, reset, dim, DEFAULT_PORT, reset } },
        .{ "   {s}-d, --dir <root directory>{s}  Server root directory      {s}(default: \"{s}\"){s}\n", .{ bold, reset, dim, DEFAULT_DIR, reset } },
        .{ "   {s}-h, --help{s}                  Display this help message \n", .{ bold, reset } },
    };

    inline for (to_print) |item| {
        writer.interface.print(item[0], item[1]) catch |e| {
            std.log.err("writing usage: {any}", .{e});
        };
    }

    writer.flush() catch |e| {
        std.log.err("flushing stdout: {any}", .{e});
    };
}
