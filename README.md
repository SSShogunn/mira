# Mira

A personal Android app for downloading media via a self-hosted [Cobalt](https://github.com/imputnet/cobalt) instance.

## Features

- **Download media** — paste a URL or share directly from any app
- **Video & audio** — toggle audio-only mode before downloading
- **Downloads folder** — files saved to `/storage/emulated/0/Download/`, always accessible
- **History** — browse past downloads, open or share files directly from the app
- **Cobalt instance management** — add your own instance with optional API key auth

## Supported Platforms

Works with any platform Cobalt supports — Instagram, Reddit, TikTok, Twitter, Soundcloud, and more.
YouTube works for most videos; newer content may be blocked by YouTube's network restrictions (upstream limitation).

## Stack

- Flutter (Android)
- [Cobalt API](https://github.com/imputnet/cobalt) — self-hosted backend
- Hive — local storage for instance config and download history
- Dio — file downloads with progress
- share_plus / open_file — file sharing and opening from history

## Setup

1. Self-host a Cobalt instance (v11+)
2. Clone this repo and run `flutter pub get`
3. Build and install: `flutter run`
4. In the app, tap **Add** under Instance and enter your Cobalt URL

## Notes

- Single instance only by design
- No Play Store release — personal use
