import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
String formatTime(TimeOfDay time) {
  final now = DateTime.now();
  return DateFormat('h:mm a')
      .format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
}

TimeOfDay parseTime(String value) {
  try {
    final d = DateFormat('h:mm a').parse(value);
    return TimeOfDay(hour: d.hour, minute: d.minute);
  } catch (_) {
    return const TimeOfDay(hour: 8, minute: 0);
  }
}
