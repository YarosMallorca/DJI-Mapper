import 'package:xml/xml.dart';

/// Used for `takePhoto`,  `startRecord`, `stopRecord` actions
class CameraControlParams extends XmlElement {
  final int payloadPosition;

  CameraControlParams({required this.payloadPosition})
      : super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:payloadPositionIndex",
            children: [XmlText(payloadPosition.toString())],
          )
        ]);
}

class GimbalRotateParams extends XmlElement {
  final double pitch;
  final int payloadPosition;

  GimbalRotateParams({required this.pitch, required this.payloadPosition})
      : super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:gimbalPitchRotateAngle",
            children: [XmlText(pitch.toString())],
          ),
          XmlElement.tag(
            "wpml:payloadPositionIndex",
            children: [XmlText(payloadPosition.toString())],
          )
        ]);
}

class HoverParams extends XmlElement {
  /// Time in seconds
  final int hoverTime;

  HoverParams({required this.hoverTime})
      : assert(hoverTime > 0, "Hover time can't be 0"),
        super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:hoverTime",
            children: [XmlText(hoverTime.toString())],
          )
        ]);
}
