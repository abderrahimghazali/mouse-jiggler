<div align="center">

# Mouse Jiggler

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)
![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A simple and intelligent macOS app that prevents your computer from going to sleep by simulating mouse movement.

<img src="mouse-jiggler.png" alt="Mouse Jiggler App" width="25%">

</div>

## Features

- **Multiple Movement Patterns**: Choose from Circular, Figure-8, Random, or Straight Line movements
- **Smart Activity Detection**: Automatically pauses when you're actively using your computer
- **Customizable Intervals**: Set movement frequency from 5 seconds to 10 minutes
- **Battery Protection**: Automatically disables when battery drops below a set threshold
- **Scheduled Deactivation**: Set a specific time to automatically turn off
- **Click Options**: Optional left or right clicks with movements
- **Launch at Login**: Start automatically when you log in
- **Keyboard Shortcut**: Toggle with Cmd+Ctrl+K
- **Menu Bar Only**: Runs discretely from the status bar

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/abderrahimghazali/mouse-jiggler.git
   cd mouse-jiggler
   ```

2. Run xcodegen to generate the Xcode project files:
   ```bash
   xcodegen generate
   ```

3. Open the generated `.xcodeproj` file in Xcode

4. Build and run on your device

### Troubleshooting

If the project doesn't compile due to LaunchAtLogin package issues:
1. In Xcode, go to Project Settings → Package Dependencies
2. Remove the LaunchAtLogin package
3. Re-add it by clicking "+" and entering: `https://github.com/sindresorhus/LaunchAtLogin-Modern`
4. Select version 5.0.0 and add to target

## Requirements

- macOS 13.0+
- Xcode 14.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation

## Usage

1. Click the mouse icon in your menu bar to open the settings
2. Toggle the main switch to activate/deactivate
3. Customize movement patterns, intervals, and other preferences
4. Use Cmd+Ctrl+K to quickly toggle from anywhere

---

<div align="center">
Created with ❤️ by <a href="https://github.com/abderrahimghazali">Abderrahim Ghazali</a>
</div>