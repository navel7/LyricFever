# LyricRise

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
- LyricRise installs separately from Lyric Fever. On first launch, you can import the old app's settings. Saved lyrics are not imported.
- This version has only been checked on macOS Golden Gate 27.2.

## First-launch warnings

**This app is ad hoc signed and has not been notarized by Apple.** Its signature does not identify a developer verified by Apple, and the app has not been checked through Apple's notarization service.

When you first open it, macOS may say that the developer cannot be verified or that Apple cannot verify the app is free of malware. The wording varies by macOS version. This is expected with this distribution method, but it does not guarantee that the app is safe. Only continue if you trust the source.

## How to install

1. Download the DMG from [the download section](https://github.com/navel7/LyricRise/releases/latest).
2. Quit LyricRise if it is running.
3. Open the DMG and drag **LyricRise.app** onto **Applications**. If asked to replace an existing LyricRise copy, confirm the replacement.
4. If macOS blocks the app because the developer cannot be verified, open **System Settings → Privacy & Security**. Find the message about LyricRise, select **Open Anyway**, and follow the prompts. Only do this if you trust the source.
5. On first launch, choose whether to import settings from Lyric Fever. To import, select **`com.aviwadhwa.SpotifyLyricsInMenubar.plist`** in the file chooser.
6. If asked, allow LyricRise to control Apple Music or Spotify. This permission is needed to follow playback. You may be asked again because the app's identity has changed.

## How to update

This version has **no automatic update feature**. Use **View Releases…** to open the download page and download a newer DMG. Quit the app, then replace it using the installation steps above.

## Reporting problems

Please report problems with this modified version to [navel7/LyricRise Issues](https://github.com/navel7/LyricRise/issues). Include your macOS version, whether you use Apple Music or Spotify, and the steps that led to the problem.
