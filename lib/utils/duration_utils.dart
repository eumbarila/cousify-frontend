class DurationUtils {
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return "${minutes}m";
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return "${hours}h";
    }

    return "${hours}h ${remainingMinutes}m";
  }

  static String formatMinutesDetailed(int minutes) {
    if (minutes < 60) {
      return minutes == 1 ? "1 minute" : "$minutes minutes";
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    String result = hours == 1 ? "1 hour" : "$hours hours";

    if (remainingMinutes > 0) {
      String minutesText = remainingMinutes == 1
          ? "1 minute"
          : "$remainingMinutes minutes";
      result += " $minutesText";
    }

    return result;
  }

  static double minutesToHours(int minutes) {
    return minutes / 60;
  }
}
