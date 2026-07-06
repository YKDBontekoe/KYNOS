import 'package:flutter/animation.dart';

/// Design token: motion durations and curves shared across the app.
abstract final class Motion {
  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 400);
  static const ringSweep = Duration(milliseconds: 600);
  static const navIndicator = Duration(milliseconds: 320);
  static const navItem = Duration(milliseconds: 220);
  static const ringStagger = Duration(milliseconds: 50);
  static const pulse = Duration(milliseconds: 900);

  static const curve = Curves.easeOutCubic;
  static const curveIn = Curves.easeInCubic;
  static const pulseCurve = Curves.easeInOut;
}
