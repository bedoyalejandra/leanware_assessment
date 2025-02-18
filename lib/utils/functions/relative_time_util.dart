import 'package:intl/intl.dart';

String formatDuration(Duration duration) {
  if (duration.inHours >= 1) {
    return '''${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}''';
  } else {
    return '''${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}''';
  }
}

String formatSeconds(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

String getRelativeTime(DateTime entry) {
  var now = DateTime.now();
  var format = DateFormat('HH:mm');
  var date = entry;
  var diff = now.difference(date);
  var time = '';
  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0) {
    time = format.format(date);
  } else if (diff.inHours > 0 && diff.inHours < 24) {
    time = '${diff.inHours} h';
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    time = '${diff.inDays} d';
  } else {
    time = '${(diff.inDays / 7).floor()} w';
  }
  return time;
}
