class CameraPreset {
  String name;
  bool defaultPreset;
  double sensorWidth;
  double sensorHeight;
  double focalLength;
  int imageWidth;
  int imageHeight;

  CameraPreset({
    required this.name,
    required this.defaultPreset,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.focalLength,
    required this.imageWidth,
    required this.imageHeight,
  });

  factory CameraPreset.fromJson(Map<String, dynamic> json) {
    return CameraPreset(
      name: json['name'],
      defaultPreset: json['defaultPreset'],
      sensorWidth: json['sensorWidth'],
      sensorHeight: json['sensorHeight'],
      focalLength: json['focalLength'],
      imageWidth: json['imageWidth'],
      imageHeight: json['imageHeight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'defaultPreset': defaultPreset,
      'sensorWidth': sensorWidth,
      'sensorHeight': sensorHeight,
      'focalLength': focalLength,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraPreset &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          defaultPreset == other.defaultPreset &&
          sensorWidth == other.sensorWidth &&
          sensorHeight == other.sensorHeight &&
          focalLength == other.focalLength &&
          imageWidth == other.imageWidth &&
          imageHeight == other.imageHeight;

  @override
  int get hashCode =>
      name.hashCode ^
      defaultPreset.hashCode ^
      sensorWidth.hashCode ^
      sensorHeight.hashCode ^
      focalLength.hashCode ^
      imageWidth.hashCode ^
      imageHeight.hashCode;
}
