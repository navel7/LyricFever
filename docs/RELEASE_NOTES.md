# Lyric Fever — navel7fork

[日本語](RELEASE_NOTES.ja.md)

This is a modified version of [Lyric Fever by aviwad](https://github.com/aviwad/LyricFever) v3.3, updated for macOS Tahoe and later. It adds Liquid Glass support and adjustable lyric timing, among other changes. It is released separately from the original app and is not an official release by its author.

## Main changes from the original

- **Glass-style background:** On macOS Tahoe 26 or later, the karaoke window uses Liquid Glass. On macOS 15, it keeps the previous background style.
- **Earlier lyric display:** Show karaoke lyrics up to 2 seconds earlier, in 0.25-second steps. Choose **Original** to use the original timing.
- **Remembered lyric position:** Lyrics return to their saved window position after restarting.
- **Manual updates:** Automatic updates and the original app's mandatory-update check are disabled. **View Releases…** opens this version's download page.

## Before installing

- Requires **macOS 15 or later** and **Apple Music or the Spotify desktop app**.
- This DMG is for **Apple Silicon Macs (M1 or later) only**. It does not support Intel Macs.
- Installing this version over the original replaces the original app. Settings and saved lyrics may be shared between them. Keep a copy of the original app if you want to switch back, and avoid running both at once.
- This version has only been checked on macOS Golden Gate 27.2.

## First-launch warnings

**This app is ad hoc signed and has not been notarized by Apple.** Its signature does not identify a developer verified by Apple, and the app has not been checked through Apple's notarization service.

When you first open it, macOS may say that the developer cannot be verified or that Apple cannot verify the app is free of malware. The wording varies by macOS version. This is expected with this distribution method, but it does not guarantee that the app is safe. Only continue if you trust the source.

## How to install

1. Download the DMG from [this version's Releases page](https://github.com/navel7/LyricFever/releases).
2. Quit Lyric Fever if it is running.
3. Open the DMG and drag **Lyric Fever.app** onto **Applications**. If asked to replace an existing copy, confirm that you want to replace it with this version before proceeding.
4. If macOS blocks the app because the developer cannot be verified, open **System Settings → Privacy & Security**. Find the message about Lyric Fever, select **Open Anyway**, and follow the prompts. Only do this if you trust the source.
5. If asked, allow Lyric Fever to control Apple Music or Spotify. This permission is needed to follow playback. You may be asked again even if you previously used the original app.

## How to update

This version has **no automatic update feature**. Use **View Releases…** to open the download page and download a newer DMG. Quit the app, then replace it using the installation steps above.

## Reporting problems

Please report problems with this modified version to [navel7/LyricFever Issues](https://github.com/navel7/LyricFever/issues). Include your macOS version, whether you use Apple Music or Spotify, and the steps that led to the problem.
