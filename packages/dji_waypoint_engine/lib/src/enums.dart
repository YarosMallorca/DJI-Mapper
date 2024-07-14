/// `safely`: The aircraft in safe mode
/// (M300) takes off, ascends to the altitude of the first waypoint, and then
/// flies level to the first waypoint. If the first waypoint is lower than the
/// take-off point, after takeoff, it will level fly to the top of the first waypoint
/// and then descend.
/// (M30) The aircraft takes off, rises to the altitude of the first waypoint,
/// and then flies level to the first waypoint. If the first waypoint is lower
/// than the "safe take-off altitude", after taking off to the "safe take-off altitude",
/// level flight to the first waypoint and then descend.
/// Note that the "safe takeoff altitude" only takes effect when the aircraft is not taking off.
///
/// `pointToPoint`: In tilt flight mode
/// (M300), after the aircraft takes off, it tilts to the first waypoint.
/// (M30) The aircraft takes off to the "safe take-off altitude", and then ramps to the first waypoint. If the altitude of the first waypoint is lower than the "safe take-off altitude", it will first level flight and then descend.
///
///https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/template-kml.html#mission-information-parent-element-wpml-missionconfig
enum FlyToWaylineMode { safely, pointToPoint }

/// `goBack`: Go back. The aircraft is flying from the out-of-control position to the take-off point
///
/// `landing`: landing. The aircraft landed in place from an out-of-control position
///
/// `hover`: hover. The aircraft is hovering from an out-of-control position
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/template-kml.html#mission-information-parent-element-wpml-missionconfig
enum RCLostAction { goBack, landing, hover }

/// `goHome`: After the aircraft completes the route task, exit the route mode and return to home.
///
/// `noAction`: After the aircraft completes the route task, it exits the route mode.
///
/// `autoLand`: After the aircraft completes the route task, it exits the route mode and lands on the spot.
///
/// `gotoFirstWaypoint`: After the aircraft completes the route task, it will
/// immediately fly to the starting point of the route, and exit route mode when it arrives.
///
/// Note: During the execution of the above actions, if the aircraft exits
/// the route mode and enters the runaway state, the runaway action will be executed first.
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/template-kml.html#mission-information-parent-element-wpml-missionconfig
enum FinishAction { goHome, autoLand, noAction, gotoFirstWaypoint }

/// 	Whether to continue to execute the route out of control
///
/// `goContinue`: Continue to execute the wayline
///
/// `executeLostAction`: Exit the route and execute the runaway action
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/template-kml.html#mission-information-parent-element-wpml-missionconfig
enum ExitOnRCLost { goContinue, executeLostAction }

/// Heading mode of the drone
///
/// `followWayline`: Along course direction. The nose of the aircraft follows the course direction to the next waypoint.
///
/// `manually`: The user can manually control the nose orientation of the aircraft during the flight to the next waypoint.
///
/// `fixed`: The nose of the aircraft maintains the yaw angle of the aircraft to the next waypoint after the waypoint action has been performed.
///
/// `smoothTransition`: Customized. The target yaw angle for a waypoint is given by `wpml:waypointHeadingAngle`
/// and transitions evenly to the target yaw angle of the next waypoint during the flight segment.
///
/// `towardPOI`: The aircraft heading faces the point of interest.
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/common-element.html#wpml-waypointheadingparam-wpml-globalwaypointheadingparam
enum HeadingMode { followWayline, manually, fixed, smoothTransition, towardPOI }

/// Direction of rotation of the aircraft yaw angle
///
/// `clockwise`
///
/// `counterClockwise`
///
/// `followBadArc`: Rotation of the aircraft yaw angle along the shortest path.
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/common-element.html#wpml-waypointheadingparam-wpml-globalwaypointheadingparam
enum HeadingPathMode { clockwise, counterClockwise, followBadArc }

/// coordinateTurn: Coordinated turns, no dips, early turns.
///
/// `toPointAndStopWithDiscontinuityCurvature`: Fly in a straight line and the aircraft stops at the point.
///
/// `toPointAndStopWithContinuityCurvature`: Fly in a curve and the aircraft stops at the point.
///
/// `toPointAndPassWithContinuityCurvature`: Fly in a curve and the aircraft will not stop at the point.
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/common-element.html#wpml-waypointturnparam
enum WaypointTurnMode {
  coordinateTurn,
  toPointAndStopWithDiscontinuityCurvature,
  toPointAndStopWithContinuityCurvature,
  toPointAndPassWithContinuityCurvature,
}

/// Undocumented in the DJI documentation
///
/// Will have to figure out what this is
///
/// My guess is that it defines if the actions should be executed at the same time
/// or in sequence, however for some of them it doesn't make sense
enum ActionMode { parallel, sequence }

/// `reachPoint`: Executed on arrival at the waypoint.
///
/// `betweenAdjacentPoints`: Flight routine segment trigger. Rotate the gimbal evenly.
///
/// `multipleTiming`: Same time trigger.
///
/// `multipleDistance`: Same distance trigger.
///
/// Note: “betweenAdjacentPoints” should be used with `gimbalEvenlyRotate`. `multipleTiming` combining with `takePhoto`
/// can achieve equal-time interval capture. `multipleDistance` combining with `takePhoto` can achieve equal-distance interval capture.
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/common-element.html#wpml-actiontrigger
enum ActionTriggerType {
  reachPoint,
  betweenAdjacentPoints,
  multipleTiming,
  multipleDistance
}

/// `customDirName`: Create new folder.
///
/// `gimbalRotate`: Gimbal rotation.
///
/// `rotateYaw`: Drone rotates around the yaw axis.
///
/// `hover`: Hover and wait.
///
///
/// More will be added soon...
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/common-element.html#wpml-action
enum ActionFunction {
  takePhoto,
  startRecord,
  stopRecord,
  gimbalEvenlyRotate,
  hover
}
