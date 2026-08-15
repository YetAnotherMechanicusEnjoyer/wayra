const std = @import("std");

const css = @import("css.zig");

pub fn render_header(
    allocator: std.mem.Allocator,
    list: *std.ArrayListUnmanaged(u8),
) !void {
    try list.appendSlice(allocator,
        \\<head>
        \\    <meta charset="UTF-8">
        \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
        \\    <link rel="icon" href="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDI0IDEwMjQiIGNsYXNzPSJpY29uIiB2ZXJzaW9uPSIxLjEiIGZpbGw9IiMwMDAwMDAiPgogIDxnIGlkPSJTVkdSZXBvX2JnQ2FycmllciIgc3Ryb2tlLXdpZHRoPSIwIj48L2c+CiAgPGcgaWQ9IlNWR1JlcG9fdHJhY2VyQ2FycmllciIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48L2c+CiAgPGcgaWQ9IlNWR1JlcG9faWNvbkNhcnJpZXIiPgogICAgPHBhdGggZD0iTTI0Mi4zIDc0My40aDYwMy40YzI3LjggMCA1MC4zLTIyLjUgNTAuMy01MC4zVjE5MkgxOTJ2NTAxLjFjMCAyNy44IDIyLjUgNTAuMyA1MC4zIDUwLjN6IiBmaWxsPSIjRkZFQTAwIj48L3BhdGg+CiAgICA8cGF0aCBkPSJNMTc4LjMgODA3LjRoNjAzLjRjMjcuOCAwIDUwLjMtMjIuNSA1MC4zLTUwLjNWMjU2SDEyOHY1MDEuMWMwIDI3LjggMjIuNSA1MC4zIDUwLjMgNTAuM3oiIGZpbGw9IiNGRkZGOEQiPjwvcGF0aD4KICAgIDxwYXRoIGQ9Ik05NjAgNTE1djM4NGMwIDM1LjMtMjguNyA2NC02NCA2NEgxMjhjLTM1LjMgMC02NC0yOC43LTY0LTY0VjM4My44YzAtMzUuMyAyOC43LTY0IDY0LTY0aDM0NC4xYzI0LjUgMCA0Ni44IDEzLjkgNTcuNSAzNS45bDQ2LjUgOTUuM0g4OTZjMzUuMyAwIDY0IDI4LjcgNjQgNjR6IiBmaWxsPSIjM0Q1QUZFIj48L3BhdGg+CiAgICA8cGF0aCBkPSJNNzA0IDUxMmMwLTIwLjctMS40LTQxLjEtNC4xLTYxSDU3Ni4xbC00Ni41LTk1LjNjLTEwLjctMjItMzMuMS0zNS45LTU3LjUtMzUuOUgxMjhjLTM1LjMgMC02NCAyOC43LTY0IDY0Vjg5OWMwIDYuNyAxIDEzLjIgMyAxOS4zQzEyNC40IDk0NSAxODguNSA5NjAgMjU2IDk2MGMyNDcuNCAwIDQ0OC0yMDAuNiA0NDgtNDQ4eiIgZmlsbD0iIzUzNkRGRSI+PC9wYXRoPgogIDwvZz4KPC9zdmc+Cg==">
        \\    <title>Wayra Explorer</title>
    );

    try css.render_css(allocator, list);

    try list.appendSlice(allocator,
        \\</head>
    );
}
