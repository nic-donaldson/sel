I've wanted this in my shell workflow for some time so today I scratched that itch.

[![asciicast](https://asciinema.org/a/D26FWkEgjqrUjnGPqxN0t3om8)](https://asciinema.org/a/D26FWkEgjqrUjnGPqxN0t3om8)

## Installation

I'm new to OCaml so I have no idea how to package this; bear with me.

## How does it work?

`sel` reads in lines from stdin until EOF, then opens /dev/tty so it can get input again.

## How doesn't it work?

I have no idea what happens if you
- feed it Unicode,
- feed it lines longer than your terminal is wide,
- or feed it more lines than your terminal is high.

I'll fix all three of those things.
