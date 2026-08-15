const std = @import("std");

pub fn render_script(allocator: std.mem.Allocator, list: *std.ArrayListUnmanaged(u8)) !void {
    try list.appendSlice(allocator,
        \\<script>
        \\    document.addEventListener('DOMContentLoaded', () => {
        \\        const modal = document.getElementById('preview-modal');
        \\        const body = document.getElementById('preview-body');
        \\        const title = document.getElementById('preview-title');
        \\        const close = document.getElementById('close-modal');
        \\        const copyBtn = document.getElementById('copy-btn');
        \\        const dlModalBtn = document.getElementById('dl-modal-btn');
        \\        const searchInput = document.getElementById('search-input');
        \\        const itemCount = document.getElementById('item-count');
        \\        const toggleBtn = document.getElementById('toggle-list-btn');
        \\
        \\        const currentParams = window.location.search;
        \\ 
        \\        if (currentParams) {
        \\            const dirLinks = document.querySelectorAll('.item-link[data-type="dir"], li[data-parent="true"] a');
        \\            dirLinks.forEach(link => {
        \\                link.href += currentParams;
        \\            });
        \\        }
        \\
        \\        let rawTextContent = "";
        \\        const updateCount = () => {
        \\            const visible = document.querySelectorAll('ul#file-list > li:not([data-parent="true"])[style*="display: flex"], ul#file-list > li:not([data-parent="true"]):not([style*="display"])').length;
        \\            itemCount.innerText = `${visible} item${visible > 1 ? 's' : ''}`;
        \\        };
        \\        updateCount();
        \\        searchInput.addEventListener('input', (e) => {
        \\            const q = e.target.value.toLowerCase();
        \\            document.querySelectorAll('ul#file-list > li').forEach(li => {
        \\                if (li.dataset.parent === "true") return;
        \\                const name = li.querySelector('.name').innerText.toLowerCase();
        \\                li.style.display = name.includes(q) ? 'flex' : 'none';
        \\            });
        \\            updateCount();
        \\        });
        \\        close.onclick = () => modal.classList.remove('active');
        \\        modal.onclick = (e) => { if (e.target === modal) modal.classList.remove('active'); };
        \\        document.addEventListener('keydown', (e) => { if (e.key === 'Escape') modal.classList.remove('active'); });
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
        \\        if (toggleBtn) {
        \\            toggleBtn.onclick = () => {
        \\                const url = new URL(window.location.href);
        \\                const params = url.searchParams;
        \\
        \\                if (params.has('list')) {
        \\                    params.delete('list');
        \\                } else {
        \\                    params.set('list', '1');
        \\                }
        \\
        \\                window.location.href = url.toString();
        \\            };
        \\
        \\            if (new URLSearchParams(window.location.search).has('list')) {
        \\                toggleBtn.style.background = 'var(--accent, #7600FF)';
        \\                toggleBtn.style.color = 'var(--text, #000000)';
        \\            }
        \\        }
        \\
        \\        const textExts = ['.txt', '.zig', '.zon', '.c', '.h', '.cpp', '.hpp', '.rs', '.go', '.py', '.js', '.ts', '.jsx', '.tsx', '.html', '.css', '.scss', '.json', '.md', '.xml', '.yaml', '.yml', '.toml', '.sh', '.bash', '.bat', '.conf', '.ini', '.csv', '.log', '.sql', '.env'];
        \\        const imgExts = ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp', '.ico', '.bmp'];
        \\        const audioExts = ['.mp3', '.wav', '.ogg', '.flac', '.m4a'];
        \\        const videoExts = ['.mp4', '.webm', '.mkv', '.mov'];
        \\        document.querySelectorAll('.item-link[data-type="file"]').forEach(link => {
        \\            link.onclick = async (e) => {
        \\                e.preventDefault();
        \\                const href = link.href;
        \\                const name = link.querySelector('.name').innerText;
        \\
        \\                let ext = '';
        \\                const lastDot = name.lastIndexOf('.');
        \\                if (lastDot > 0) ext = name.substring(lastDot).toLowerCase();
        \\                title.innerText = name;
        \\                dlModalBtn.href = href;
        \\                dlModalBtn.download = name;
        \\                copyBtn.style.display = 'none';
        \\                body.innerHTML = '<div class="no-preview">Loading...</div>';
        \\                modal.classList.add('active');
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
        \\                        rawTextContent = text;
        \\                        copyBtn.style.display = 'flex';
        \\                        const escaped = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        \\                        body.innerHTML = `<pre><code>${escaped}</code></pre>`;
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
        \\    });
        \\</script>
    );
}
