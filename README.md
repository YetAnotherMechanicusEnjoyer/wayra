# wayra

<p align="center"> 
  <img alt="AUR Stable Version" src="https://img.shields.io/aur/version/wayra?style=for-the-badge&logo=archlinux&logoColor=white&label=wayra&labelColor=1793D1&link=https%3A%2F%2Faur.archlinux.org%2Fpackages%2Fwayra">
  <img alt="AUR Latest Version" src="https://img.shields.io/aur/version/wayra-git?style=for-the-badge&logo=archlinux&logoColor=white&label=wayra-git&labelColor=1793D1&link=https%3A%2F%2Faur.archlinux.org%2Fpackages%2Fwayra-git">

  <br>

  <img alt="AUR Publisher" src="https://img.shields.io/github/actions/workflow/status/YetAnotherMechanicusEnjoyer/wayra/aur.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=AUR%20Publisher&labelColor=010409&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fwayra%2Factions%2Fworkflows%2Faur.yml">
  <img alt="Binaries Publisher" src="https://img.shields.io/github/actions/workflow/status/YetAnotherMechanicusEnjoyer/wayra/bin.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=Binaries%20Publisher&labelColor=010409&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fwayra%2Factions%2Fworkflows%2Fbin.yml">
  <img alt="Zig CI" src="https://img.shields.io/github/actions/workflow/status/YetAnotherMechanicusEnjoyer/wayra/zig.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=Zig%20CI&labelColor=010409&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fwayra%2Factions%2Fworkflows%2Fzig.yml">
  
  <br>

  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/YetAnotherMechanicusEnjoyer/wayra?display_timestamp=committer&style=for-the-badge&logo=github&labelColor=010409">
  <img alt="GitHub License" src="https://img.shields.io/github/license/YetAnotherMechanicusEnjoyer/wayra?style=for-the-badge&logo=gplv3&logoColor=white&labelColor=010409&color=BD0000&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fwayra%2Fblob%2F97f424c116b690a2703a5e83d5a9bddcaeec8545%2FLICENSE">
</p>

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

## Installation

### Arch Linux ([AUR](https://aur.archlinux.org/packages/wayra))

Requires any AUR Helper like [YaY](https://github.com/Jguer/yay)

e.g.:
```bash
yay -S wayra        # Stable version
                    # or
yay -S wayra-git    # Latest version
```

### Binaries

Download prebuilt binaries from [releases](https://github.com/YetAnotherMechanicusEnjoyer/wayra/releases/)

### From Source

**0. Prerequesites**

To build and run this project from source, you will need [Zig 0.16.0](https://ziglang.org/download/).

**1. Clone the repository**
```bash
git clone https://github.com/YetAnotherMechanicusEnjoyer/wayra.git
cd wayra
```

**2. Build the executable using the Zig build system**
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
wayra --dir /path/to/your/folder
```

*(Note: Adjust the command line arguments based on your specific implementation. If the server serves the current working directory by default, simply running `wayra` is sufficient.)*

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
