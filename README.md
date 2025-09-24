# Mouse Jiggler

A simple and intelligent macOS app that prevents your computer from going to sleep by simulating mouse movement.

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

## Requirements

- macOS 11.0+
- Xcode 12.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation

## Usage

1. Click the mouse icon in your menu bar to open the settings
2. Toggle the main switch to activate/deactivate
3. Customize movement patterns, intervals, and other preferences
4. Use Cmd+Ctrl+K to quickly toggle from anywhere

## License

MIT License - feel free to use and modify as needed.