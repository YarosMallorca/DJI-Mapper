import 'package:test/test.dart';
import 'package:litchi_waypoint_engine/engine.dart';

void main() {
  group('Action', () {
    test('Action with actionParam should not throw an exception', () {
      expect(
        () => Action(actionType: ActionType.rotateAircraft, actionParam: 90.0),
        returnsNormally,
      );
    });

    test('Action without actionParam should throw an exception', () {
      expect(
        () => Action(actionType: ActionType.stayFor),
        throwsA(isA<AssertionError>()),
      );
    });

    test('getActionId returns correct action ID', () {
      expect(Action.getActionId(ActionType.takePhoto), equals(1));
      expect(Action.getActionId(ActionType.startRecording), equals(2));
      expect(Action.getActionId(ActionType.stopRecording), equals(3));
      expect(Action.getActionId(ActionType.rotateAircraft), equals(4));
      expect(Action.getActionId(ActionType.tiltCamera), equals(5));
    });
  });
}
