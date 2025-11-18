import '../l10n/app_localizations.dart';

class TimeFormatter {
  static String formatDuration(Duration value, AppLocalizations loc) {
    if (value == Duration.zero) {
      return loc.playtimeEmpty;
    }
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    return '${hours} ${loc.statsHoursSuffix}  ${minutes} ${loc.statsMinutesSuffix}  ${seconds} ${loc.statsSecondsSuffix}';
  }

  static String formatModeDuration(Duration value, AppLocalizations loc) {
    if (value == Duration.zero) {
      return loc.modeTimeUnavailable;
    }
    return formatDuration(value, loc);
  }
}
