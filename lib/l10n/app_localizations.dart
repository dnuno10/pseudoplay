import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PseudoPlay'**
  String get appTitle;

  /// No description provided for @splashLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Booting retro core…'**
  String get splashLoadingMessage;

  /// No description provided for @splashInitPreferences.
  ///
  /// In en, this message translates to:
  /// **'Loading your preferences'**
  String get splashInitPreferences;

  /// No description provided for @splashTapToStart.
  ///
  /// In en, this message translates to:
  /// **'PRESS START'**
  String get splashTapToStart;

  /// No description provided for @splashProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get splashProgressLabel;

  /// No description provided for @nameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your codename'**
  String get nameDialogTitle;

  /// No description provided for @nameDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the name that will appear on the consoles.'**
  String get nameDialogMessage;

  /// No description provided for @nameDialogPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get nameDialogPlaceholder;

  /// No description provided for @nameDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get nameDialogConfirm;

  /// No description provided for @nameDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get nameDialogCancel;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name to continue.'**
  String get nameRequiredError;

  /// No description provided for @menuFlashcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pseudocode flashcards'**
  String get menuFlashcardsTitle;

  /// No description provided for @menuFlashcardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Flip retro cards to memorize every reserved word between INICIO and FIN.'**
  String get menuFlashcardsDescription;

  /// No description provided for @menuFlashcardsCTA.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get menuFlashcardsCTA;

  /// No description provided for @menuPlayButton.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get menuPlayButton;

  /// No description provided for @menuUserPrefix.
  ///
  /// In en, this message translates to:
  /// **'USR>'**
  String get menuUserPrefix;

  /// No description provided for @menuEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEditButton;

  /// No description provided for @menuExecuteTitle.
  ///
  /// In en, this message translates to:
  /// **'Run pseudocode'**
  String get menuExecuteTitle;

  /// No description provided for @menuExecuteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write and execute algorithms step by step without friction.'**
  String get menuExecuteSubtitle;

  /// No description provided for @menuBlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocks mode'**
  String get menuBlocksTitle;

  /// No description provided for @menuBlocksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag-and-drop retro blocks to build algorithms visually.'**
  String get menuBlocksSubtitle;

  /// No description provided for @menuPlaytimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time played'**
  String get menuPlaytimeLabel;

  /// No description provided for @menuAlgorithmsLabel.
  ///
  /// In en, this message translates to:
  /// **'Algorithms executed'**
  String get menuAlgorithmsLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch the entire retro interface to your preferred language.'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsRenameButton.
  ///
  /// In en, this message translates to:
  /// **'Change player name'**
  String get settingsRenameButton;

  /// No description provided for @settingsClearCacheButton.
  ///
  /// In en, this message translates to:
  /// **'Clear cache and restart'**
  String get settingsClearCacheButton;

  /// No description provided for @settingsClearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? All local progress, name, and preferences will be erased.'**
  String get settingsClearCacheConfirm;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'We only store your local play stats on this device. Nothing is uploaded.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get settingsTermsTitle;

  /// No description provided for @settingsTermsBody.
  ///
  /// In en, this message translates to:
  /// **'Use PseudoPlay responsibly. The retro vibes are provided as-is, without warranties.'**
  String get settingsTermsBody;

  /// No description provided for @privacyDialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get privacyDialogClose;

  /// No description provided for @termsViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsViewTitle;

  /// No description provided for @termsViewIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Using PseudoPlay'**
  String get termsViewIntroTitle;

  /// No description provided for @termsViewIntroBody.
  ///
  /// In en, this message translates to:
  /// **'PseudoPlay is a learning tool for experimenting with algorithms. By continuing you agree to use it respectfully and only for educational purposes.'**
  String get termsViewIntroBody;

  /// No description provided for @termsViewContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Content ownership'**
  String get termsViewContentTitle;

  /// No description provided for @termsViewContentBody.
  ///
  /// In en, this message translates to:
  /// **'All retro assets, copy, and visual style remain property of the PseudoPlay team. Please do not redistribute without permission.'**
  String get termsViewContentBody;

  /// No description provided for @termsViewWarrantyTitle.
  ///
  /// In en, this message translates to:
  /// **'Warranty and liability'**
  String get termsViewWarrantyTitle;

  /// No description provided for @termsViewWarrantyBody.
  ///
  /// In en, this message translates to:
  /// **'PseudoPlay is provided as-is without guarantees. We are not liable for data loss, interruptions, or damages caused by misuse.'**
  String get termsViewWarrantyBody;

  /// No description provided for @termsViewUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get termsViewUpdatesTitle;

  /// No description provided for @termsViewUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'We may update these terms as new builds ship. We\'ll highlight meaningful changes within the app whenever possible.'**
  String get termsViewUpdatesBody;

  /// No description provided for @privacyViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyViewTitle;

  /// No description provided for @privacyViewIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'What we store'**
  String get privacyViewIntroTitle;

  /// No description provided for @privacyViewIntroBody.
  ///
  /// In en, this message translates to:
  /// **'PseudoPlay stores your player name, execution stats, and preferences locally on your device so you can keep playing offline.'**
  String get privacyViewIntroBody;

  /// No description provided for @privacyViewDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No cloud sync'**
  String get privacyViewDataTitle;

  /// No description provided for @privacyViewDataBody.
  ///
  /// In en, this message translates to:
  /// **'We never send your information to external servers. Clearing the cache deletes everything permanently.'**
  String get privacyViewDataBody;

  /// No description provided for @privacyViewControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Your control'**
  String get privacyViewControlTitle;

  /// No description provided for @privacyViewControlBody.
  ///
  /// In en, this message translates to:
  /// **'You can reset all saved data anytime from the danger zone inside settings.'**
  String get privacyViewControlBody;

  /// No description provided for @privacyViewContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions?'**
  String get privacyViewContactTitle;

  /// No description provided for @privacyViewContactBody.
  ///
  /// In en, this message translates to:
  /// **'Reach out to the PseudoPlay team if you have doubts about this policy or need help managing your data.'**
  String get privacyViewContactBody;

  /// No description provided for @statsHoursSuffix.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get statsHoursSuffix;

  /// No description provided for @statsMinutesSuffix.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get statsMinutesSuffix;

  /// No description provided for @statsSecondsSuffix.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get statsSecondsSuffix;

  /// No description provided for @statsAlgorithmsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} algorithms'**
  String statsAlgorithmsValue(int count);

  /// No description provided for @languageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get languageDialogTitle;

  /// No description provided for @playtimeEmpty.
  ///
  /// In en, this message translates to:
  /// **'0 h 0 m 0 s'**
  String get playtimeEmpty;

  /// No description provided for @snackbarNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Player name updated!'**
  String get snackbarNameUpdated;

  /// No description provided for @snackbarCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared. Restarting…'**
  String get snackbarCacheCleared;

  /// No description provided for @snackbarLanguageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get snackbarLanguageUpdated;

  /// No description provided for @splashMissingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'We need your player name to continue.'**
  String get splashMissingNameTitle;

  /// No description provided for @modeTimeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No playtime recorded yet'**
  String get modeTimeUnavailable;

  /// No description provided for @settingsOpenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Read privacy'**
  String get settingsOpenPrivacy;

  /// No description provided for @settingsOpenTerms.
  ///
  /// In en, this message translates to:
  /// **'Read terms'**
  String get settingsOpenTerms;

  /// No description provided for @flashcardsIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore each card to learn how to write common operations between INICIO and FIN. Tap to flip and view the full example.'**
  String get flashcardsIntroDescription;

  /// No description provided for @genericBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get genericBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
