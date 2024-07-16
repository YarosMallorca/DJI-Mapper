# DJI Mapper

A cross-platform tool to plan and create automatic Survey/Photogrammetry missions for DJI Drones with Waypoints!

![Home page Screenshot](https://github.com/user-attachments/assets/127ec817-1c62-4cfb-a5d2-a6c1801238a4)

## Features

- **Cross-platform**: Works on Windows, Linux and MacOS.
- **Easy to use**: Just a few clicks to create a mission.
- **Customizable**: Change the mission parameters to fit your needs.
- **Works with DJI Drones**: Compatible with DJI Drones that support Waypoints.
- **Works with Litchi**: Export missions to Litchi for DJI Drones that don't support Waypoints. (coming soon)

## Installation

1. Download the latest version from the [Releases](https://github.com/YarosMallorca/DJI-Mapper/releases/latest) page.

2. If you're on Windows, unzip the downloaded file and run `DJI Mapper.exe`. On MacOS simply double-click the downloaded file. On Linux run `DJI-Mapper` from the terminal.

3. If you're on Windows and you get a warning from Windows Defender, click on "More info" and then "Run anyway".

## Usage

1. Find the area you want to survey on the map.
2. Click on the map to add waypoints.
3. Set the Aircraft parameters according to your needs.
4. Select the camera you're using from the presets, or create a custom one.
5. On the Info tab, you can see general info about the mission.
6. On the Export tab, click the button to export the mission to a file.
7. Load the mission on your drone and start the mission. (detailed instructions coming soon)
   _Note: Do not modify or save the mission from inside DJI Fly, beucase it doesn't support straight curves, and will break the mission._

## Contributing

Contributions are most welcome! If you have any ideas, suggestions or issues, please open an issue or a pull request.

## Building from source

**Requirements:**

- Dart SDK
- Flutter SDK

1. Clone the repository.
2. Run `flutter pub get` to install the dependencies.
3. Run `flutter build <platform>` to build the app for your platform or `flutter run` to run it on your device.
4. Run `flutter build <platform> --release` to build the release version.

- Recommend using VSCode with the Flutter extension for development, it will allow Hot-Reload and other features.
