# DJI Mapper

A cross-platform tool to plan and create automatic Survey/Photogrammetry missions for DJI Drones with Waypoints!

<div>
<img src="https://github.com/user-attachments/assets/127ec817-1c62-4cfb-a5d2-a6c1801238a4" height="300px" />
<img src="https://github.com/user-attachments/assets/7ba5ac8f-bac7-4c4c-9671-a2c3f7f0207d" height="300px" />
<img src="https://github.com/user-attachments/assets/f94518bd-5776-42d5-9dc5-267a274b919b" height="250px" />


</div>

## Features

- **Cross-platform**: Works on Windows, Linux, MacOS & Android.
- **Easy to use**: Just a few clicks to create a mission.
- **Customizable**: Change the mission parameters to fit your needs.
- **Works with DJI Fly**: Compatible with DJI Drones that support Waypoints.
- **Works with Litchi**: Export missions to Litchi for DJI Drones that don't support Waypoints.

## Supported Aircraft

- **DJI Fly**: DJI Mini 4 Pro, DJI Air 3, DJI Mavic 3, Mavic 3 Cine, Mavic 3 Classic
- **Litchi**: Mini 2, Mini SE (NOT Mini 4K), Air 2S, Mavic Mini 1, Mavic Air 2, Mavic 2 Zoom/Pro, Mavic Air 1, Mavic Pro 1, Phantom 4 (Standard/Advanced/Pro/ProV2), Phantom 3 (Standard/4K/Advanced/Professional), Inspire 1 (X3/Z3/Pro/RAW), Inspire 2 and Spark
- **Litchi Pilot Beta**: Mini 3, Mini 3 Pro, Mavic 3E, Mavic 3T
  
**IMPORTANT NOTE regarding Litchi Pilot**: I haven't tested how well Litchi Pilot plays with DJI-Mapper, so I can't guarantee a smooth experience. 

## Installation

1. Download the latest version from the [Releases](https://github.com/YarosMallorca/DJI-Mapper/releases/latest) page.

2. Unzip the downloaded file and run the executable. On Linux run `DJI-Mapper` from the terminal.

3. If you're on Windows and you get a warning from Windows Defender, click on "More info" and then "Run anyway".

## Usage

1. Find the area you want to survey on the map.
2. Click on the map to add waypoints.
3. Set the Aircraft parameters according to your needs.
4. Select the camera you're using from the presets, or create a custom one.
5. On the Info tab, you can see general info about the mission.
6. On the Export tab, click the button to export the mission to a file.
7. Load the mission on your drone and start the mission. (detailed instructions can be found by clicking three dots on the top and going to "Help loading mission" page)

_Note: Do not modify or save the mission from inside DJI Fly, because it doesn't support straight curves, and will break the mission._

## Contributing

Contributions are most welcome! If you have any ideas, suggestions, or issues, please open an issue or a pull request.

## Building from source

**Requirements:**

- Dart SDK
- Flutter SDK

1. Clone the repository.
2. Run `flutter pub get` to install the dependencies.
3. Run `flutter build <platform>` to build the app for your platform or `flutter run` to run it on your device.
4. Run `flutter build <platform> --release` to build the release version.

- Recommend using VSCode with the Flutter extension for development, it will allow Hot-Reload and other features.
