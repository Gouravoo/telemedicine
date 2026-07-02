import 'package:intl/intl.dart';

/// Date and text formatters used across the app
class AppFormatters {
  AppFormatters._();

  /// Format date: "Jul 5, 2026"
  static String date(DateTime dt) => DateFormat('MMM d, y').format(dt);

  /// Format short date: "5 Jul"
  static String dateShort(DateTime dt) => DateFormat('d MMM').format(dt);

  /// Format date with day: "Monday, Jul 5"
  static String dateWithDay(DateTime dt) => DateFormat('EEEE, MMM d').format(dt);

  /// Format time: "09:30 AM"
  static String time(DateTime dt) => DateFormat('hh:mm a').format(dt);

  /// Format full: "Jul 5, 2026 at 09:30 AM"
  static String dateTime(DateTime dt) =>
      DateFormat('MMM d, y \'at\' hh:mm a').format(dt);

  /// Format relative time: "2 hours ago", "3 days ago"
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dt);
  }

  /// Format currency: "₹800"
  static String currency(double amount) =>
      '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

  /// Format rating: "4.8"
  static String rating(double r) => r.toStringAsFixed(1);

  /// Capitalize first letter
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
