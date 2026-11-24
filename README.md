# GlassCenter

مركز تحكم جديد بتخطيط iOS 18 وتأثير زجاجي (Liquid Glass) مستوحى من iOS 26، لأجهزة الجلبريك.

A new Control Center for jailbroken devices: iOS 18 layout with an iOS 26 Liquid Glass look.

## Layout
| Area | Controls |
|------|----------|
| Connectivity card (2x2) | Airplane, Wi-Fi, Bluetooth, Low Power |
| Now Playing (2x2) | Artwork, title, artist, previous / play-pause / next |
| Sliders (1x2) | Brightness, Volume |
| Small tiles (2x2) | Rotation Lock, Lock Screen, Settings, Respring |
| Shortcut row | Flashlight, Timer, Calculator, Camera |

## Usage
Swipe down from the **top edge** of the screen to open. Tap outside or swipe up to close.
(This replaces the stock Notification Center swipe; the stock Control Center is untouched.)

## Requirements
- Jailbroken iOS 15+ (rootless, e.g. palera1n on A10 devices like iPhone 7)
- [Theos](https://theos.dev)

## Build
```bash
make clean package FINALPACKAGE=1
make install THEOS_DEVICE_IP=<device-ip>   # optional
```
For a rootful jailbreak, remove the `THEOS_PACKAGE_SCHEME = rootless` line in the Makefile and use `Architecture: iphoneos-arm` in `control`.

## Structure
| File | Purpose |
|------|---------|
| `Tweak.xm` | SpringBoard hooks, window creation |
| `GCWindow.m` | Overlay window, grid layout, gestures, animations |
| `GCGlass.m` | Glass helper, tile/button, vertical slider |
| `GCNowPlaying.m` | Now Playing card (MediaRemote) |
| `GCSystem.m` | System controls wrapper (private APIs) |
| `GCPrivate.h` | Private API declarations |

## Notes
- Private APIs change between iOS versions. Everything uses runtime lookup and `respondsToSelector:` so a missing API disables one control instead of crashing.
- On iOS 15 the glass falls back to a dark blur material; `UIGlassEffect` is used automatically on iOS 26.
- Portrait only. Not affiliated with Apple.

## License
MIT
