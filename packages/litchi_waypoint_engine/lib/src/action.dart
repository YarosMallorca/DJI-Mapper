import 'enums.dart';

Map<ActionType, int> _actionTypeMap = {
  ActionType.stayFor: 0,
  ActionType.takePhoto: 1,
  ActionType.startRecording: 2,
  ActionType.stopRecording: 3,
  ActionType.rotateAircraft: 4,
  ActionType.tiltCamera: 5
};

class Action {
  final ActionType actionType;
  final double? actionParam;

  Action({required this.actionType, this.actionParam})
      : assert(
            !((actionType == ActionType.stayFor ||
                    actionType == ActionType.rotateAircraft ||
                    actionType == ActionType.tiltCamera) &&
                actionParam == null),
            "ActionParam is required for this action type");

  static int getActionId(ActionType actionType) => _actionTypeMap[actionType]!;
}
