# Audible Sleep Timer (macOS)

A lightweight macOS script that acts as a sleep timer for Audible or any Safari playback.

## How it works
- Prompts for a sleep duration (default 15 min)
- Prevents system sleep using `caffeinate`
- Dims the screen and fades volume
- Pauses Safari playback
- Waits for a spacebar press to restart

## Requirements
- macOS with Python 3
- [`brightness`](https://github.com/nriley/brightness) (install with `brew install brightness`)
- Safari for playback

## Usage
```bash
chmod +x SleepTimer.command wait_for_space.py
./SleepTimer.command

