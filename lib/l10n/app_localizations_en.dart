// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PseudoPlay';

  @override
  String get splashLoadingMessage => 'Booting retro core…';

  @override
  String get splashInitPreferences => 'Loading your preferences';

  @override
  String get splashTapToStart => 'PRESS START';

  @override
  String get splashProgressLabel => 'Loading';

  @override
  String get nameDialogTitle => 'Choose your codename';

  @override
  String get nameDialogMessage =>
      'Enter the name that will appear on the consoles.';

  @override
  String get nameDialogPlaceholder => 'Player name';

  @override
  String get nameDialogConfirm => 'Save';

  @override
  String get nameDialogCancel => 'Cancel';

  @override
  String get nameRequiredError => 'Please enter a name to continue.';

  @override
  String get menuFlashcardsTitle => 'Pseudocode flashcards';

  @override
  String get menuFlashcardsDescription =>
      'Flip retro cards to memorize every reserved word between INICIO and FIN.';

  @override
  String get menuFlashcardsCTA => 'Play';

  @override
  String get menuPlayButton => 'Play';

  @override
  String get menuUserPrefix => 'USR>';

  @override
  String get menuEditButton => 'Edit';

  @override
  String get menuExecuteTitle => 'Run pseudocode';

  @override
  String get menuExecuteSubtitle =>
      'Write and execute algorithms step by step without friction.';

  @override
  String get menuBlocksTitle => 'Blocks mode';

  @override
  String get menuBlocksSubtitle =>
      'Drag-and-drop retro blocks to build algorithms visually.';

  @override
  String get menuPlaytimeLabel => 'Time played';

  @override
  String get menuAlgorithmsLabel => 'Algorithms executed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageDescription =>
      'Switch the entire retro interface to your preferred language.';

  @override
  String get settingsRenameButton => 'Change player name';

  @override
  String get settingsClearCacheButton => 'Clear cache and restart';

  @override
  String get settingsClearCacheConfirm =>
      'Are you sure? All local progress, name, and preferences will be erased.';

  @override
  String get settingsPrivacyTitle => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'We only store your local play stats on this device. Nothing is uploaded.';

  @override
  String get settingsTermsTitle => 'Terms and Conditions';

  @override
  String get settingsTermsBody =>
      'Use PseudoPlay responsibly. The retro vibes are provided as-is, without warranties.';

  @override
  String get privacyDialogClose => 'Close';

  @override
  String get termsViewTitle => 'Terms and Conditions';

  @override
  String get termsViewIntroTitle => 'Using PseudoPlay';

  @override
  String get termsViewIntroBody =>
      'PseudoPlay is a learning tool for experimenting with algorithms. By continuing you agree to use it respectfully and only for educational purposes.';

  @override
  String get termsViewContentTitle => 'Content ownership';

  @override
  String get termsViewContentBody =>
      'All retro assets, copy, and visual style remain property of the PseudoPlay team. Please do not redistribute without permission.';

  @override
  String get termsViewWarrantyTitle => 'Warranty and liability';

  @override
  String get termsViewWarrantyBody =>
      'PseudoPlay is provided as-is without guarantees. We are not liable for data loss, interruptions, or damages caused by misuse.';

  @override
  String get termsViewUpdatesTitle => 'Updates';

  @override
  String get termsViewUpdatesBody =>
      'We may update these terms as new builds ship. We\'ll highlight meaningful changes within the app whenever possible.';

  @override
  String get privacyViewTitle => 'Privacy Policy';

  @override
  String get privacyViewIntroTitle => 'What we store';

  @override
  String get privacyViewIntroBody =>
      'PseudoPlay stores your player name, execution stats, and preferences locally on your device so you can keep playing offline.';

  @override
  String get privacyViewDataTitle => 'No cloud sync';

  @override
  String get privacyViewDataBody =>
      'We never send your information to external servers. Clearing the cache deletes everything permanently.';

  @override
  String get privacyViewControlTitle => 'Your control';

  @override
  String get privacyViewControlBody =>
      'You can reset all saved data anytime from the danger zone inside settings.';

  @override
  String get privacyViewContactTitle => 'Questions?';

  @override
  String get privacyViewContactBody =>
      'Reach out to the PseudoPlay team if you have doubts about this policy or need help managing your data.';

  @override
  String get statsHoursSuffix => 'h';

  @override
  String get statsMinutesSuffix => 'm';

  @override
  String get statsSecondsSuffix => 's';

  @override
  String statsAlgorithmsValue(int count) {
    return '$count algorithms';
  }

  @override
  String get languageDialogTitle => 'Select language';

  @override
  String get playtimeEmpty => '0 h 0 m 0 s';

  @override
  String get snackbarNameUpdated => 'Player name updated!';

  @override
  String get snackbarCacheCleared => 'Cache cleared. Restarting…';

  @override
  String get snackbarLanguageUpdated => 'Language updated';

  @override
  String get splashMissingNameTitle => 'We need your player name to continue.';

  @override
  String get modeTimeUnavailable => 'No playtime recorded yet';

  @override
  String get settingsOpenPrivacy => 'Read privacy';

  @override
  String get settingsOpenTerms => 'Read terms';

  @override
  String get flashcardsIntroDescription =>
      'Explore each card to learn how to write common operations between INICIO and FIN. Tap to flip and view the full example.';

  @override
  String get genericBack => 'Back';
}
