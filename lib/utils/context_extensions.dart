import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

extension LocalizationX on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
