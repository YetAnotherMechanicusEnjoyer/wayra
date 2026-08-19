# wayra

A lightweight, high-performance standalone web server and directory explorer written in Zig. 

wayra serves local directories over HTTP and provides a modern, responsive single-page web interface to browse, preview, and interact with files directly from the browser (inspired by Python's builtin HTTP server).

## Features

- **Instant File Previews:**
  - **Markdown:** Native rendering within an isolated environment and live Source/Preview toggling.
  - **HTML:** Secure, isolated rendering via sandboxed iframes.
  - **Media:** In-browser playback and viewing for images, audio, and video files.
  - **Code & Text:** Raw code viewer with line numbers.
- **Real-time Filtering:** Client-side search to quickly filter files within the current directory.
- **Zero Frontend Build Step:** The frontend relies strictly on standard web technologies (HTML/CSS/JS). External libraries (like `marked.js`) are fetched dynamically at runtime only when needed.

## Prerequisites

To build and run this project from source, you will need [Zig 0.16.0](https://ziglang.org/download/).

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/YetAnotherMechanicusEnjoyer/wayra.git
cd wayra
```

### 2. Build the executable using the Zig build system
```bash
zig build -Doptimize=ReleaseFast
```
The compiled binary will be available in the `zig-out/bin/` directory.

## Usage
```bash
$ wayra -h
:: Usage:
   wayra [OPTIONS]

:: Options:
   -b, --bind <host> <port>    Server address             (default: :: 8000)
   -d, --dir <root directory>  Server root directory      (default: ".")
   -h, --help                  Display this help message
```

To start the server, run the built executable and specify the root directory you want to serve.
```bash
./zig-out/bin/wayra --dir /path/to/your/folder
```

*(Note: Adjust the command line arguments based on your specific implementation. If the server serves the current working directory by default, simply running `./zig-out/bin/wayra` is sufficient.)*

Once the server is running, open your web browser and navigate to one of the following:
```bash
http://[::1]:8000
http://localhost:8000
http://<address>:<port>
```

## Supported Files Formats for Preview

* **Rendered:** `.md`, `.html`
* **Images:** `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.webp`, `.ico`
* **Video/Audio:** `.mp4`, `.webm`, `.mkv`, `.mov`, `.mp3`, `.wav`, `.ogg`, `.flac`, `.m4a`
* **Documents**: `.pdf`
* **Text/Code:** *any file not containing null bytes.*

## Contributing
Contributions are welcome. Please ensure that your code adheres to the existing style and that you test your changes locally before submitting a pull request.

## License
[![GPL-3.0](https://img.shields.io/github/license/YetAnotherMechanicusEnjoyer/wayra?style=for-the-badge&logo=github&color=2EA44F)](https://github.com/YetAnotherMechanicusEnjoyer/wayra/blob/738bbebb25ac510da9e3f1d3b36c2fc59f36b2e1/LICENSE)
