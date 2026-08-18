const std = @import("std");

pub fn get_stat(io: std.Io, path: []const u8, stat: std.Io.Dir.Stat) std.Io.Dir.Stat {
    var target_stat = stat;
    if (stat.kind == .sym_link) {
        var resolved_buf: [std.fs.max_path_bytes]u8 = undefined;
        if (std.Io.Dir.cwd().realPathFile(io, path, &resolved_buf)) |resolved_len| {
            const resolved_path = resolved_buf[0..resolved_len];
            if (std.Io.Dir.cwd().statFile(io, resolved_path, .{})) |resolved_stat| {
                target_stat = resolved_stat;
            } else |_| {}
        } else |_| {}
    }
    return target_stat;
}

pub fn is_curl(req: *std.http.Server.Request) bool {
    var it = req.iterateHeaders();
    while (it.next()) |header| {
        if (std.ascii.eqlIgnoreCase(header.name, "user-agent")) {
            return std.mem.startsWith(u8, header.value, "curl/");
        }
    }
    return false;
}

pub fn ipToString(ip: std.Io.net.IpAddress, buffer: []u8) ![]u8 {
    switch (ip) {
        .ip4 => |ip4| {
            return std.fmt.bufPrint(
                buffer,
                "{d}.{d}.{d}.{d}:{d}",
                .{ ip4.bytes[0], ip4.bytes[1], ip4.bytes[2], ip4.bytes[3], ip4.port },
            );
        },
        .ip6 => |ip6| {
            var words: [8]u16 = undefined;
            for (0..8) |i| {
                words[i] = (@as(u16, ip6.bytes[i * 2]) << 8) | ip6.bytes[i * 2 + 1];
            }
            return std.fmt.bufPrint(
                buffer,
                "[{x}:{x}:{x}:{x}:{x}:{x}:{x}:{x}]:{d}",
                .{
                    words[0], words[1], words[2], words[3],
                    words[4], words[5], words[6], words[7],
                    ip6.port,
                },
            );
        },
    }
}
