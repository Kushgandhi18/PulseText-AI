// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorTitle => 'An error occurred';

  @override
  String get getStarted => 'Get Started';

  @override
  String get goHome => 'Go Home';

  @override
  String get notFoundMessage => '404 - Page not found!';

  @override
  String get speechToTextAppBarTitle => 'Real-time Speech Recognition';

  @override
  String get speechToTextHint => 'Transcribed text will appear here...';

  @override
  String get tapToStart => 'Tap to Start';

  @override
  String get listening => 'Listening...';

  @override
  String get onboardingSubTitle =>
      'Instant transcription for clear, efficient communication';

  @override
  String get onboardingTitle => 'Speech-to-Text in Real-Time';
}
