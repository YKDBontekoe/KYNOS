/// Formats today's date as "Mon, Jan 5".
String formatDateLabel([DateTime? date]) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final now = date ?? DateTime.now();
  return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
}
