import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String format({
    String pattern = 'yyyy-MM-dd',
    String? locale,
  }) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(this);
  }

  String formatDate(String locale) {
    return format(pattern: 'yyyy-MM-dd', locale: locale);
  }

  String formatDateTime(String locale) {
    return format(pattern: 'yyyy-MM-dd HH:mm', locale: locale);
  }

  String timeAgo(String locale) {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 7) return formatDate(locale);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  bool get isExpired => isBefore(DateTime.now());
  bool get isUpcoming => isAfter(DateTime.now());
}
