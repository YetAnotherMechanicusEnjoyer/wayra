const std = @import("std");

pub fn render_css(allocator: std.mem.Allocator, list: *std.ArrayListUnmanaged(u8)) !void {
    try list.appendSlice(allocator, "<style>\n");

    try list.appendSlice(allocator, get_theme());
    try list.appendSlice(allocator, get_body());
    try list.appendSlice(allocator, get_header_breadcrumbs_search());
    try list.appendSlice(allocator, get_item_list());
    try list.appendSlice(allocator, get_preview());
    try list.appendSlice(allocator, get_preview_lines());

    try list.appendSlice(allocator, "</style>\n");
}

fn get_theme() []const u8 {
    return
    \\        :root {
    \\            --bg: #090d16;
    \\            --card: #111827;
    \\            --card-hover: #1f2937;
    \\            --border: #1e293b;
    \\            --text: #f3f4f6;
    \\            --text-muted: #94a3b8;
    \\            --accent: #38bdf8;
    \\            --accent-glow: rgba(56, 189, 248, 0.15);
    \\        }
    \\        @media (prefers-color-scheme: light) {
    \\            :root {
    \\                --bg: #f8fafc;
    \\                --card: #ffffff;
    \\                --card-hover: #f1f5f9;
    \\                --border: #e2e8f0;
    \\                --text: #0f172a;
    \\                --text-muted: #64748b;
    \\                --accent: #0284c7;
    \\                --accent-glow: rgba(2, 132, 199, 0.15);
    \\            }
    \\        }
    \\
    ;
}

fn get_body() []const u8 {
    return
    \\        * { box-sizing: border-box; }
    \\        body {
    \\            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    \\            margin: 0;
    \\            padding: 2rem 1rem;
    \\            background-color: var(--bg);
    \\            color: var(--text);
    \\            display: flex;
    \\            justify-content: center;
    \\        }
    \\        .container {
    \\            width: 100%;
    \\            max-width: 900px;
    \\        }
    \\
    ;
}

fn get_header_breadcrumbs_search() []const u8 {
    return
    \\        header { margin-bottom: 1.5rem; }
    \\        .top-bar {
    \\            display: flex;
    \\            justify-content: space-between;
    \\            align-items: center;
    \\            margin-bottom: 1rem;
    \\        }
    \\        .brand {
    \\            display: flex;
    \\            align-items: center;
    \\            gap: 0.5rem;
    \\            font-weight: 700;
    \\            font-size: 1.1rem;
    \\            color: var(--accent);
    \\        }
    \\        .count-badge {
    \\            background: var(--card);
    \\            border: 1px solid var(--border);
    \\            color: var(--text-muted);
    \\            padding: 0.25rem 0.6rem;
    \\            border-radius: 20px;
    \\            font-size: 0.8rem;
    \\        }
    \\        .breadcrumbs {
    \\            display: flex;
    \\            flex-wrap: wrap;
    \\            align-items: center;
    \\            gap: 0.4rem;
    \\            font-family: ui-monospace, monospace;
    \\            font-size: 0.95rem;
    \\        }
    \\        .crumb {
    \\            color: var(--text-muted);
    \\            text-decoration: none;
    \\            padding: 0.2rem 0.4rem;
    \\            border-radius: 4px;
    \\            transition: all 0.15s;
    \\        }
    \\        .crumb:hover {
    \\            color: var(--accent);
    \\            background: var(--card);
    \\        }
    \\        .crumb.current {
    \\            color: var(--text);
    \\            font-weight: 600;
    \\        }
    \\        .sep { color: var(--border); }
    \\
    \\        .header-actions { margin-bottom: 1.2rem; }
    \\        .search-box {
    \\            position: relative;
    \\            margin-bottom: 1.2rem;
    \\        }
    \\        .search-box input {
    \\            width: 100%;
    \\            padding: 0.75rem 1rem 0.75rem 2.6rem;
    \\            background: var(--card);
    \\            border: 1px solid var(--border);
    \\            border-radius: 10px;
    \\            color: var(--text);
    \\            font-size: 0.9rem;
    \\            outline: none;
    \\            transition: all 0.2s;
    \\        }
    \\        .search-box input:focus {
    \\            border-color: var(--accent);
    \\            box-shadow: 0 0 0 3px var(--accent-glow);
    \\        }
    \\        .search-icon {
    \\            position: absolute;
    \\            left: 0.9rem;
    \\            top: 50%;
    \\            transform: translateY(-50%);
    \\            width: 18px;
    \\            height: 18px;
    \\            fill: none;
    \\            stroke: var(--text-muted);
    \\        }
    \\
    ;
}

fn get_item_list() []const u8 {
    return
    \\        ul {
    \\            list-style: none;
    \\            padding: 0;
    \\            margin: 0;
    \\            display: flex;
    \\            flex-direction: column;
    \\            gap: 0.4rem;
    \\        }
    \\        li {
    \\            display: flex;
    \\            align-items: center;
    \\            background: var(--card);
    \\            border: 1px solid var(--border);
    \\            border-radius: 10px;
    \\            transition: all 0.15s;
    \\            overflow: hidden;
    \\        }
    \\        li:hover {
    \\            background: var(--card-hover);
    \\            border-color: var(--border);
    \\            transform: translateY(-1px);
    \\        }
    \\        .item-link {
    \\            display: flex;
    \\            align-items: center;
    \\            padding: 0.75rem 1rem;
    \\            flex-grow: 1;
    \\            text-decoration: none;
    \\            color: var(--text);
    \\            overflow: hidden;
    \\            gap: 0.75rem;
    \\        }
    \\        .icon-wrapper {
    \\            width: 26px;
    \\            height: 26px;
    \\            display: flex;
    \\            align-items: center;
    \\            justify-content: center;
    \\            flex-shrink: 0;
    \\        }
    \\        .icon-wrapper svg {
    \\            width: 100%;
    \\            height: 100%;
    \\        }
    \\        .name {
    \\            font-family: ui-monospace, monospace;
    \\            font-size: 0.9rem;
    \\            white-space: nowrap;
    \\            overflow: hidden;
    \\            text-overflow: ellipsis;
    \\            flex-grow: 1;
    \\        }
    \\        .badge {
    \\            font-size: 0.7rem;
    \\            font-family: ui-monospace, monospace;
    \\            padding: 0.15rem 0.4rem;
    \\            border-radius: 4px;
    \\            background: rgba(255,255,255,0.05);
    \\            color: var(--text-muted);
    \\            text-transform: uppercase;
    \\            border: 1px solid var(--border);
    \\        }
    \\        .dl-btn {
    \\            display: flex;
    \\            align-items: center;
    \\            justify-content: center;
    \\            padding: 0.75rem 1rem;
    \\            color: var(--text-muted);
    \\            border-left: 1px solid var(--border);
    \\            text-decoration: none;
    \\            transition: all 0.15s;
    \\        }
    \\        .dl-btn:hover { 
    \\            color: var(--accent);
    \\            background: var(--accent-glow);
    \\        }
    \\        .dl-btn svg { 
    \\            width: 18px;
    \\            height: 18px;
    \\        }
    \\
    ;
}

fn get_preview() []const u8 {
    return
    \\        #preview-modal {
    \\            display: none;
    \\            position: fixed;
    \\            inset: 0;
    \\            background: rgba(9, 13, 22, 0.85);
    \\            z-index: 100;
    \\            padding: 0;
    \\            backdrop-filter: blur(8px);
    \\        }
    \\        #preview-modal.active {
    \\            display: flex;
    \\            justify-content: center;
    \\            align-items: center;
    \\        }
    \\        .modal-content {
    \\            display: flex;
    \\            flex-direction: column;
    \\             width: 100%;
    \\             max-width: 1500px;
    \\             height: 85vh;
    \\             background: var(--card);
    \\             border: 1px solid var(--border);
    \\             border-radius: 14px;
    \\             overflow: hidden;
    \\             box-shadow: 0 20px 40px rgba(0,0,0,0.5);
    \\        }
    \\        #preview-header {
    \\            display: flex;
    \\            justify-content: space-between;
    \\            align-items: center;
    \\            padding: 0.8rem 1.2rem;
    \\            border-bottom: 1px solid var(--border);
    \\            background: var(--card);
    \\        }
    \\        #preview-title {
    \\            font-weight: 600;
    \\            font-family: ui-monospace, monospace;
    \\            font-size: 0.95rem;
    \\            text-overflow: ellipsis;
    \\            overflow: hidden;
    \\            white-space: nowrap;
    \\        }
    \\        .modal-actions {
    \\            display: flex;
    \\            gap: 0.5rem;
    \\            align-items: center;
    \\        }
    \\        .btn {
    \\            background: var(--border);
    \\            border: none;
    \\            color: var(--text);
    \\            padding: 0.4rem 0.7rem;
    \\            border-radius: 6px;
    \\            font-size: 0.8rem;
    \\            cursor: pointer;
    \\            transition: background 0.15s;
    \\            display: flex;
    \\            align-items: center;
    \\            gap: 0.3rem;
    \\        }
    \\        .btn:hover {
    \\            background: var(--card-hover);
    \\            color: var(--accent);
    \\        }
    \\        #preview-body {
    \\            flex-grow: 1;
    \\            overflow: hidden;
    \\            display: flex;
    \\            justify-content: center;
    \\            align-items: center;
    \\            background: var(--bg);
    \\        }
    \\        #preview-body img {
    \\            max-width: 100%;
    \\            max-height: 100%;
    \\            object-fit: contain;
    \\            border-radius: 6px;
    \\        }
    \\        #preview-body video, #preview-body audio {
    \\            max-width: 100%;
    \\        }
    \\        #preview-body pre { 
    \\            width: 100%;
    \\            height: 100%;
    \\            margin: 0;
    \\            overflow: auto;
    \\            padding: 1.2rem;
    \\            padding-left: 0.4rem;
    \\            background: #070a10;
    \\            color: #e2e8f0;
    \\            border-radius: 14px;
    \\            border-top-left-radius: 0;
    \\            border-top-right-radius: 0;
    \\            font-family: ui-monospace, monospace;
    \\            font-size: 0.85rem;
    \\            line-height: 1.5;
    \\            border: 1px solid var(--border);
    \\        }
    \\        .no-preview { 
    \\            color: var(--text-muted);
    \\            text-align: center;
    \\            font-style: italic;
    \\            font-size: 0.9rem;
    \\        }
    \\
    ;
}

fn get_preview_lines() []const u8 {
    return
    \\        .code-container {
    \\            margin: 0;
    \\            padding: 0;
    \\            overflow-x: auto;
    \\            font-family: monospace;
    \\            font-size: 0.9rem;
    \\            line-height: 1.5;
    \\        }
    \\        .code-line {
    \\            display: flex;
    \\        }
    \\        .line-num {
    \\            min-width: 3rem;
    \\            padding-right: 1rem;
    \\            text-align: right;
    \\            color: #6e7681;
    \\            user-select: none;
    \\            flex-shrink: 0;
    \\            border-right: 1px solid rgba(255, 255, 255, 0.1);
    \\            margin-right: 1rem;
    \\        }
    \\        .line-content {
    \\            white-space: pre;
    \\        }
    \\
    ;
}
