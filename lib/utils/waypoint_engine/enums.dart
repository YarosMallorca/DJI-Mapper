enum RCLostAction { goBack, landing, hover }

enum FinishAction { goHome, autoLand, gotoFirstWaypoint }

enum HeadingMode { followWayline, manually, fixed, smoothTransition, towardPOI }

enum HeadingPathMode { clockwise, counterClockwise, followBadArc }

enum WaypointTurnMode {
  coordinateTurn,
  toPointAndStopWithDiscontinuityCurvature,
  toPointAndStopWithContinuityCurvature,
  toPointAndPassWithContinuityCurvature,
}

enum ActionMode { parallel, sequence }

enum ActionTriggerType { reachPoint, betweenAdjacentPoints, multipleTiming, multipleDistance }

enum ActionFunction { takePhoto, startRecord, stopRecord, focus, zoom, customDirName, gimbalRotate, rotateYaw, hover }
