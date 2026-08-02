# Typewriter Plugin (打字机插件)

> **中文简介**：一个基于 AutoHotkey v2 的轻量级打字机插件，能把剪贴板里的文字像真人一样**逐字打出**。支持快捷键开关、按任意键停止、保留空格换行格式、实时调速，内置运行时开箱即用。适用于 Word、记事本、网页、聊天软件等任何能输入文字的地方。
>
> **English**: A lightweight AutoHotkey v2 tool that types clipboard text **character by character**, simulating real human typing. Works anywhere you can type — Word, Notepad, browsers, chat apps, etc. Features toggle shortcut, stop-on-any-key, format preservation, real-time speed control, and a bundled runtime with zero installation.

## 效果演示 / Demo

```
剪贴板内容:  Hello 世界！
              ↓  按 Ctrl+V（打字机模式已开启）
实际输出:    H → e → l → l → o →  → 世 → 界 → ！
              每个字逐个打出，按任意键即可停止
```

## 使用场景 / Use Cases

- **录入模拟**：模拟真人打字效果，适合演示场景
- **防检测**：避免一次性粘贴被系统识别为机器操作
- **直播/录屏**：让观众看到文字逐字出现的过程
- **跨应用输入**：在不支持粘贴的地方用打字方式输入

---

A lightweight AutoHotkey v2 tool that types clipboard text **character by character**, simulating real human typing. Works anywhere you can type — Word, Notepad, browsers, chat apps, etc.

## Features

- **Character-by-character typing** — pastes clipboard content one character at a time
- **Mode toggle** — press `Ctrl+Alt+D` to enable/disable; when enabled, `Ctrl+V` types instead of pasting
- **Format preservation** — spaces, tabs, and line breaks are preserved
- **Stop on any key** — press any key during typing to stop immediately
- **Adjustable speed** — speed up / slow down in real time
- **Background operation** — runs silently in the system tray, no window needed
- **Portable** — bundled AutoHotkey runtime, no installation required

## Quick Start

1. Double-click `启动打字机.bat` (Launch Typewriter.bat)
2. Press `Ctrl+Alt+D` to enable Typewriter Mode
3. Copy any text (`Ctrl+C`)
4. Click where you want to type, then press `Ctrl+V`
5. The text will be typed character by character instead of pasted
6. Press any key to stop typing at any time
7. Press `Ctrl+Alt+D` again to disable and restore normal paste

## Shortcuts

| Shortcut | Action |
|----------|--------|
| **Ctrl+Alt+D** | **Toggle Typewriter Mode** (enable/disable char-by-char paste) |
| Ctrl+Alt+T | Manual start typing (reads clipboard) |
| Ctrl+Alt+P | Pause / Resume |
| Ctrl+Alt+S | Stop |
| Ctrl+Alt++ | Speed up (interval -10ms) |
| Ctrl+Alt+- | Slow down (interval +10ms) |
| Ctrl+Alt+Q | Quit |
| **Any key** | **Press any key during typing to stop immediately** |

## File Structure

```
打字机插件/
├── 启动打字机.bat      ← Double-click to launch
├── Typewriter.ahk      ← Core script (AutoHotkey v2)
├── 使用说明.md          ← Usage documentation (Chinese)
└── AutoHotkey/
    └── AutoHotkey64.exe ← Bundled runtime (no install needed)
```

## Requirements

- Windows 10/11 (64-bit)
- No additional software needed — AutoHotkey runtime is bundled

## Auto Start

To run at startup, create a shortcut to `启动打字机.bat` and place it in the startup folder:
- Press `Win+R` → type `shell:startup` → press Enter → drop the shortcut in

## How It Works

The script uses the Windows `SendInput` API to send Unicode characters directly, bypassing the input method editor (IME) for maximum compatibility with Chinese and other non-ASCII text. Line breaks are sent as `{Enter}` and tabs as `{Tab}` to ensure proper formatting across all applications.
