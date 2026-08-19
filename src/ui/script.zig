const std = @import("std");

pub fn render_script(allocator: std.mem.Allocator, list: *std.ArrayListUnmanaged(u8)) !void {
    try list.appendSlice(allocator,
        \\<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
        \\<script>
        \\    document.addEventListener('DOMContentLoaded', () => {
        \\
    );

    try list.appendSlice(allocator, get_dom_variables());
    try list.appendSlice(allocator, get_url_params());
    try list.appendSlice(allocator, get_search_filter());
    try list.appendSlice(allocator, get_modal_event());
    try list.appendSlice(allocator, get_toggle_list_btn());
    try list.appendSlice(allocator, get_toggle_render_preview_btn());
    try list.appendSlice(allocator, get_file_preview());

    try list.appendSlice(allocator,
        \\    });
        \\</script>
        \\
    );
}

fn get_dom_variables() []const u8 {
    return
    \\        const modal = document.getElementById('preview-modal');
    \\        const body = document.getElementById('preview-body');
    \\        const title = document.getElementById('preview-title');
    \\        const close = document.getElementById('close-modal');
    \\        const copyBtn = document.getElementById('copy-btn');
    \\        const dlModalBtn = document.getElementById('dl-modal-btn');
    \\        const searchInput = document.getElementById('search-input');
    \\        const itemCount = document.getElementById('item-count');
    \\        const toggleRenderBtn = document.getElementById('toggle-render-btn');
    \\
    \\        let rawTextContent = "";
    \\        let currentExt = "";
    \\        let isRendered = false;
    \\
    \\        function renderRawCode() {
    \\            const lines = rawTextContent.split('\n');
    \\            const formatted = lines.map((line, idx) => {
    \\                const escaped = line.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    \\                return `<div class="code-line"><span class="line-num">${idx + 1}</span><span class="line-content">${escaped || ' '}</span></div>`;
    \\            }).join('');
    \\            body.innerHTML = `<pre class="code-container"><code>${formatted}</code></pre>`;
    \\        }
    \\
    \\        function updatePreviewView() {
    \\            if (isRendered) {
    \\                toggleRenderBtn.style.background = 'var(--accent, #7600FF)';
    \\                toggleRenderBtn.style.color = 'var(--text, #000000)';
    \\                copyBtn.style.display = 'none';
    \\
    \\                body.innerHTML = '';
    \\                const iframe = document.createElement('iframe');
    \\
    \\                if (currentExt === '.md') {
    \\                    iframe.style.cssText = 'width: 100%; height: 100%; border: none; background: #0d1117; border-radius: 4px;';
    \\
    \\                    const mdHtml = typeof marked !== 'undefined' ? marked.parse(rawTextContent) : 'Error: marked.js is missing';
    \\
    \\                    iframe.srcdoc = `
    \\                        <!DOCTYPE html>
    \\                        <html lang="en">
    \\                        <head>
    \\                            <meta charset="UTF-8">
    \\                            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown-dark.min.css">
    \\                            <style>
    \\                                :root {
    \\                                    --color-canvas-default: #0B101E;
    \\                                    --color-canvas-subtle: #151C2D;
    \\                                    --color-border-default: #1E293B;
    \\                                    --color-border-muted: #1E293B;
    \\                                    --color-fg-default: #E2E8F0;
    \\                                    --color-fg-muted: #94A3B8;
    \\                                    --color-accent-fg: #00E5FF;
    \\                                    --color-accent-emphasis: #00E5FF;
    \\                                }
    \\
    \\                                body {
    \\                                    margin: 0;
    \\                                    padding: 24px;
    \\                                    background-color: var(--color-canvas-default) !important;
    \\                                }
    \\                                html, body { height: 100%; overflow-y: auto; }
    \\
    \\                                ::-webkit-scrollbar { width: 8px; }
    \\                                ::-webkit-scrollbar-track { background: var(--color-canvas-default); }
    \\                                ::-webkit-scrollbar-thumb { background: #2A364F; border-radius: 4px; }
    \\                                ::-webkit-scrollbar-thumb:hover { background: var(--color-accent-fg); }
    \\
    \\                                .markdown-body a { color: var(--color-accent-fg) !important; text-decoration: none; }
    \\                                .markdown-body a:hover { text-decoration: underline; }
    \\                            </style>
    \\                        </head>
    \\                        <body class="markdown-body">
    \\                            ${mdHtml}
    \\                        </body>
    \\                        </html>
    \\                    `;
    \\                    body.appendChild(iframe);
    \\                } else if (currentExt === '.html') {
    \\                    iframe.style.cssText = 'width: 100%; height: 100%; border: none; background: white; border-radius: 4px;';
    \\                    iframe.srcdoc = rawTextContent;
    \\                    body.appendChild(iframe);
    \\                }
    \\            } else {
    \\                toggleRenderBtn.style.background = '';
    \\                toggleRenderBtn.style.color = '';
    \\                copyBtn.style.display = 'flex';
    \\                renderRawCode();
    \\            }
    \\        }
    \\
    ;
}

fn get_url_params() []const u8 {
    return
    \\        const currentParams = window.location.search;
    \\        if (currentParams) {
    \\            const dirLinks = document.querySelectorAll('.item-link[data-type="dir"], li[data-parent="true"] a');
    \\            dirLinks.forEach(link => {
    \\                link.href += currentParams;
    \\            });
    \\        }
    \\
    ;
}

fn get_search_filter() []const u8 {
    return
    \\        const updateCount = () => {
    \\            const visible = document.querySelectorAll('ul#file-list > li:not([data-parent="true"])[style*="display: flex"], ul#file-list > li:not([data-parent="true"]):not([style*="display"])').length;
    \\            itemCount.innerText = `${visible} item${visible > 1 ? 's' : ''}`;
    \\        };
    \\        updateCount();
    \\
    \\        searchInput.addEventListener('input', (e) => {
    \\            const q = e.target.value.toLowerCase();
    \\            document.querySelectorAll('ul#file-list > li').forEach(li => {
    \\                if (li.dataset.parent === "true") return;
    \\                const name = li.querySelector('.name').innerText.toLowerCase();
    \\                li.style.display = name.includes(q) ? 'flex' : 'none';
    \\            });
    \\            updateCount();
    \\        });
    \\
    ;
}

fn get_modal_event() []const u8 {
    return
    \\        close.onclick = () => modal.classList.remove('active');
    \\        modal.onclick = (e) => { if (e.target === modal) modal.classList.remove('active'); };
    \\        document.addEventListener('keydown', (e) => { if (e.key === 'Escape') modal.classList.remove('active'); });
    \\
    \\        copyBtn.onclick = () => {
    \\            const textArea = document.createElement("textarea");
    \\            textArea.value = rawTextContent;
    \\            textArea.style.position = "fixed";
    \\            textArea.style.left = "-9999px";
    \\            document.body.appendChild(textArea);
    \\            textArea.focus();
    \\            textArea.select();
    \\            try {
    \\                const successful = document.execCommand('copy');
    \\                copyBtn.innerText = successful ? 'Copied!' : 'Failed';
    \\            } catch (err) {
    \\                console.error('Cannot copy', err);
    \\                copyBtn.innerText = 'Error';
    \\            }
    \\            document.body.removeChild(textArea);
    \\            setTimeout(() => copyBtn.innerText = 'Copy', 2000);
    \\        };
    \\
    ;
}

fn get_toggle_list_btn() []const u8 {
    return
    \\        const toggleBtn = document.getElementById('toggle-list-btn');
    \\
    \\        if (toggleBtn) {
    \\            toggleBtn.onclick = () => {
    \\                const url = new URL(window.location.href);
    \\                const params = url.searchParams;
    \\                if (params.has('render')) {
    \\                    params.delete('render');
    \\                } else {
    \\                    params.set('render', '1');
    \\                }
    \\                window.location.href = url.toString();
    \\            };
    \\
    \\            if (new URLSearchParams(window.location.search).has('render')) {
    \\                toggleBtn.style.background = 'var(--accent, #7600FF)';
    \\                toggleBtn.style.color = 'var(--text, #000000)';
    \\            }
    \\        }
    \\
    ;
}

fn get_toggle_render_preview_btn() []const u8 {
    return
    \\        if (toggleRenderBtn) {
    \\            toggleRenderBtn.onclick = () => {
    \\                isRendered = !isRendered;
    \\                updatePreviewView();
    \\            };
    \\        }
    \\
    ;
}

fn get_file_preview() []const u8 {
    return
    \\        const textExts = ['.txt', '.zig', '.zon', '.c', '.h', '.cpp', '.hpp', '.rs', '.go', '.py', '.js', '.ts', '.jsx', '.tsx', '.html', '.css', '.scss', '.json', '.md', '.xml', '.yaml', '.yml', '.toml', '.sh', '.bash', '.bat', '.conf', '.ini', '.csv', '.log', '.sql', '.env'];
    \\        const imgExts = ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp', '.ico', '.bmp'];
    \\        const audioExts = ['.mp3', '.wav', '.ogg', '.flac', '.m4a'];
    \\        const videoExts = ['.mp4', '.webm', '.mkv', '.mov'];
    \\        const renderExts = ['.md', '.html'];
    \\
    \\        document.querySelectorAll('.item-link[data-type="file"]').forEach(link => {
    \\            link.onclick = async (e) => {
    \\                e.preventDefault();
    \\                const href = link.href;
    \\                const name = link.querySelector('.name').innerText;
    \\
    \\                let ext = '';
    \\                const lastDot = name.lastIndexOf('.');
    \\                if (lastDot > 0) ext = name.substring(lastDot).toLowerCase();
    \\
    \\                currentExt = ext;
    \\
    \\                title.innerText = name;
    \\                dlModalBtn.href = href;
    \\                dlModalBtn.download = name;
    \\                copyBtn.style.display = 'none';
    \\                toggleRenderBtn.style.display = renderExts.includes(ext) ? 'flex' : 'none';
    \\                body.innerHTML = '<div class="no-preview">Loading...</div>';
    \\                modal.classList.add('active');
    \\
    \\                if (imgExts.includes(ext)) {
    \\                    body.innerHTML = `<img src="${href}" alt="${name}">`;
    \\                } else if (audioExts.includes(ext)) {
    \\                    body.innerHTML = `<audio controls src="${href}"></audio>`;
    \\                } else if (videoExts.includes(ext)) {
    \\                    body.innerHTML = `<video controls src="${href}"></video>`;
    \\                } else if (ext === '.pdf') {
    \\                    body.innerHTML = `<embed src="${href}" width="100%" height="100%" />`;
    \\                } else {
    \\                    try {
    \\                        const res = await fetch(href);
    \\                        if (!res.ok) throw new Error('Network error');
    \\                        const text = await res.text();
    \\                        if (text.indexOf('\0') !== -1) throw new Error('binary');
    \\
    \\                        rawTextContent = text;
    \\
    \\                        if (renderExts.includes(ext)) {
    \\                            isRendered = true;
    \\                            updatePreviewView();
    \\                        } else {
    \\                            isRendered = false;
    \\                            copyBtn.style.display = 'flex';
    \\                            renderRawCode();
    \\                        }
    \\                    } catch (err) {
    \\                        if (err.message === 'binary') {
    \\                            body.innerHTML = `<div class="no-preview">Binary executable file.<br><br><a href="${href}" download style="color: var(--accent);">Download File</a></div>`;
    \\                        } else {
    \\                            body.innerHTML = '<div class="no-preview">Error loading file content.</div>';
    \\                        }
    \\                    }
    \\                }
    \\            };
    \\        });
    \\
    ;
}
