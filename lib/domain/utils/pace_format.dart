/// Formats pace as `m:ss /km` from seconds per kilometer.
String formatPacePerKm(double secondsPerKm) {
  if (secondsPerKm.isNaN || secondsPerKm.isInfinite || secondsPerKm <= 0) {
    return '—';
  }
  final paceMin = secondsPerKm ~/ 60;
  final paceSec = (secondsPerKm % 60).round();
  return '$paceMin:${paceSec.toString().padLeft(2, '0')} /km';
}

/// Pace from duration and distance; returns null when distance is unknown.
String? formatPaceFromSession({
  required Duration duration,
  required double? distanceMeters,
}) {
  if (distanceMeters == null || distanceMeters <= 0) return null;
  final secondsPerKm = duration.inSeconds / (distanceMeters / 1000);
  return formatPacePerKm(secondsPerKm);
}

/// Formats workout duration as `hh:mm` or `Xh Ym`.
String formatRunDuration(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes % 60;
  final s = duration.inSeconds % 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
