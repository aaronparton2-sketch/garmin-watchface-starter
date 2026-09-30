# CLAUDE.md: instructions for Claude

You are helping someone with **no coding experience** build their own Garmin watch face.
This folder is a working starter watch face written in **Monkey C** (Garmin's language)
for the **Connect IQ SDK**. It already builds and runs. Your job is to change it into the
watch face they describe, one small step at a time.

## How to work with this person

- Assume they have never coded. Explain what you're doing in one plain sentence, no jargon.
- Make **one change at a time**, build it, and ask them to check it in the simulator
  before moving on. Small wins keep them going.
- When something fails, read the error yourself and fix it. Don't hand them the error.
- If they ask for something the watch can't do (see "Limits" below), say so kindly and
  offer the closest thing that works.

## The files

| File | What it is |
|---|---|
| `source/StarterView.mc` | **Everything drawn on screen.** Most changes happen here. |
| `source/StarterApp.mc` | Entry point. Rarely needs changing. |
| `manifest.xml` | App ID, name, the list of supported watches, permissions. |
| `resources/strings/strings.xml` | The watch face's name and any text labels. |
| `resources/settings/` | Options the user can change in the Connect IQ phone app. |
| `resources/drawables/` | Images (the launcher icon). |
| `monkey.jungle` | Build config. Leave it alone. |

## How to build and run

Preferred: the **Monkey C** VS Code extension. Tell the user to press `F5`
(or Command Palette → `Monkey C: Run`) and pick their watch. It builds and opens the simulator.

From the terminal (Windows, adjust the SDK version folder to theirs):

```
set SDK=%APPDATA%\Garmin\ConnectIQ\Sdks\<their-sdk-folder>\bin
"%SDK%\monkeyc.bat" -d fr965 -f monkey.jungle -o bin\watchface.prg -y developer_key.der -w
"%SDK%\connectiq.bat"
"%SDK%\monkeydo.bat" bin\watchface.prg fr965
```

Mac: the SDK lives under `~/Library/Application Support/Garmin/ConnectIQ/Sdks/`.
Replace `fr965` with their watch's product id (list: `manifest.xml`, or the folders in
`%APPDATA%\Garmin\ConnectIQ\Devices`).

For their real watch: `Monkey C: Build for Device`, then copy the `.prg` into
`GARMIN\APPS` on the watch over a USB **data** cable.

## Rules

- 🔴 **Never commit `developer_key.der`** (or any `*.der` / `*.pem`). It is their signing
  key. It is in `.gitignore`; keep it there.
- Position everything as a **fraction of the screen** (`w * 0.5`, `h * 0.7`), never fixed
  pixels, so it works on every watch size. Round screens clip the corners, so keep text
  inside roughly the middle 80%.
- Black background. AMOLED watches burn battery on bright pixels.
- Keep `onUpdate()` light. No loops over big data, no web calls in it.
- After every change, build for at least one round watch and check the simulator.

## Limits (tell the user when they hit one)

- A watch face redraws about **once a minute**, not every second, to save battery.
- A watch face **cannot make web requests from the main view**. Live data from the
  internet (surf, weather, prices, scores) needs a **background service** with the
  `Background` and `Communications` permissions, refreshing at most every 5 minutes
  (30 is kinder to the battery). The phone must be connected by Bluetooth.
- Background code needs the `(:background)` annotation on the delegate class,
  `getServiceDelegate()`, `onBackgroundData()` and anything they use. **The simulator
  works without it, the real watch silently doesn't.** This is the most common trap.
- Memory is tiny (roughly 64-128 KB for a watch face). Keep images small and few.
- Working example of live internet data, background service and settings:
  https://github.com/aaronparton2-sketch/swellvision

## Publishing (only when they ask)

1. Put their own UUID in `manifest.xml` (generate a new one).
2. Build the store package: Command Palette → `Monkey C: Export Project` (makes a `.iq`).
3. Upload at https://apps-developer.garmin.com with a 500x500 icon, a screenshot, a plain
   text description, and a privacy policy URL if it uses location or the internet.
