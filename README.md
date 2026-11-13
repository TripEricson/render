# RENDER — RabbitEars NextGen Data Evaluator and Reporter

**Version 0.4.1**

RENDER parses ATSC 3.0 signals and writes the results as an HTML report, similar to the TSReader HTML Export format. It was written with the help of Google Gemini and Anthropic Claude. It targets the Linux command line, but should compile on the Mac with the right prerequisites, and getting it working on Windows should be possible.

## Supported input formats

**Packet data**
- HDHomeRun Debug
- IPv4-PCAP
- ALP-PCAP
- STLTP-PCAP (partial)

**Text data**
- HDHomeRun `plpinfo` format
- HDHomeRun `l1detail` format
- HDHomeRun TUI text output format

Unless the packet data is STLTP-PCAP, you need both the packet data and the text data for full information. The best combination at present is an ALP-PCAP plus either the `l1detail` string or the HDHomeRun TUI text output, from an HDHomeRun with the Dev upgrade. Give the two files the same name. Together they provide everything RENDER can currently parse.

## What it decodes

Supported or mostly supported:

- PLP information (if any text data is available)
- L1 Basic and L1 Detail (if `l1detail` or TUI text from a Dev unit is available)
- Link Mapping Table (ALP-PCAP or STLTP-PCAP)
- Service List Table
- Capability Descriptor Table (signal signing)
- Broadcast Positioning System
- ROUTE-based audio/video and data streams
- Most other LLS tables, including AEAT, RRT, SMT, etc.
- Basic info on MPEG-TS packets
- Data usage analysis (fully supported only for ALP-PCAP or STLTP-PCAP)
- Minimal eGPS support
- Partial ESG support

### Known issues

- **MMT media**: the MMT parsing is believed to work, but no station appears to transmit the signaling it needs to work properly. A workaround is in place, but it captures the audio/video parameters only some of the time and should not be considered reliable.
- **ESG**: some stations still show no ESG data, or incomplete ESG data. This will continue to be reviewed.
- **eGPS**: RENDER displays the raw eGPS data, but it appears to be a proprietary format with little or no public documentation. Attempts to reverse-engineer it beyond minimal header support have been unsuccessful.
- **Bitrates**: the usage chart always shows total data and packet counts. For the debug and IPv4 input formats, the data needed for bitrates is missing and probably cannot be reverse-engineered.

## Building

### Ubuntu / Debian

```bash
sudo apt install build-essential pkg-config libpcap-dev libxml2-dev zlib1g-dev \
    libssl-dev libavcodec-dev libavutil-dev libcurl4-openssl-dev libhdhomerun-dev
```

### Red Hat / Fedora

```bash
sudo dnf install gcc make pkgconf libpcap-devel libxml2-devel zlib-devel \
    openssl-devel libcurl-devel libhdhomerun-devel ffmpeg-devel
```

(`ffmpeg-devel` comes from RPM Fusion.)

Then build:

```bash
make
```

This produces an executable named `render`.

## Running

Put a PCAP or debug file in the folder with the executable. Then create a text file with the same name, ending in `.txt`, containing the output of the HDHomeRun `plpinfo` command and, if available, the `l1detail` string.

If you use the latest HDHomeRun TUI instead, pressing `a` or `z` to capture a debug or PCAP file produces a matching capture and `.txt` file automatically.

Then run:

```bash
./render <pcap or debug file>
```

RENDER writes an HTML file with the same name for you to review.

## Feedback

RENDER is highly experimental. If any output looks questionable, or you have questions or comments, reach me by e-mail at webmaster@rabbitears.info or on the [RabbitEars Discord](https://discord.gg/tnamT4eccd).

## Credits

- **drmpeg**: his L1 detail parsing code from [dtv-utils](https://github.com/drmpeg/dtv-utils) has been adapted for RENDER. Like RENDER, it is licensed under GPLv3.
- **FFmpeg / libavcodec**: licensed under the LGPL 2.1.
- **AC-4 patch**: [ffmpeg-with-ac4](https://github.com/funnymanva/ffmpeg-with-ac4), licensed under the MIT license.

## License

RENDER is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See [LICENSE](LICENSE).
