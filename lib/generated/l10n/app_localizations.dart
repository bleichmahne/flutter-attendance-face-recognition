import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Tracker'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @searchUserByUuid.
  ///
  /// In en, this message translates to:
  /// **'Search user by UUID'**
  String get searchUserByUuid;

  /// No description provided for @userImageRecognition.
  ///
  /// In en, this message translates to:
  /// **'User image recognition'**
  String get userImageRecognition;

  /// No description provided for @userImageRecognitionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 photos, club, voucher'**
  String get userImageRecognitionSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @clubsAndReportCards.
  ///
  /// In en, this message translates to:
  /// **'Clubs & Report Cards'**
  String get clubsAndReportCards;

  /// No description provided for @clubs.
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get clubs;

  /// No description provided for @reportCards.
  ///
  /// In en, this message translates to:
  /// **'Report Cards'**
  String get reportCards;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noClubsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No clubs available'**
  String get noClubsAvailable;

  /// No description provided for @noReportCards.
  ///
  /// In en, this message translates to:
  /// **'No report cards'**
  String get noReportCards;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @clubsAndReportCardsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Clubs and report cards will appear here'**
  String get clubsAndReportCardsEmptyHint;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @take3PicturesOfUser.
  ///
  /// In en, this message translates to:
  /// **'Take 3 pictures of user'**
  String get take3PicturesOfUser;

  /// No description provided for @take3PhotosInSequence.
  ///
  /// In en, this message translates to:
  /// **'Take 3 photos in sequence'**
  String get take3PhotosInSequence;

  /// No description provided for @photoNOf3.
  ///
  /// In en, this message translates to:
  /// **'Photo {n} of 3...'**
  String photoNOf3(int n);

  /// No description provided for @orTapBoxToTakeOrReplace.
  ///
  /// In en, this message translates to:
  /// **'Or tap a box to take or replace that photo'**
  String get orTapBoxToTakeOrReplace;

  /// No description provided for @photoN.
  ///
  /// In en, this message translates to:
  /// **'Photo {n}'**
  String photoN(int n);

  /// No description provided for @selectClub.
  ///
  /// In en, this message translates to:
  /// **'Select club'**
  String get selectClub;

  /// No description provided for @chooseClub.
  ///
  /// In en, this message translates to:
  /// **'Choose club'**
  String get chooseClub;

  /// No description provided for @voucherNumber.
  ///
  /// In en, this message translates to:
  /// **'Voucher number'**
  String get voucherNumber;

  /// No description provided for @enterVoucherNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter voucher number'**
  String get enterVoucherNumber;

  /// No description provided for @clearImages.
  ///
  /// In en, this message translates to:
  /// **'Clear images'**
  String get clearImages;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @userRegisteredFor.
  ///
  /// In en, this message translates to:
  /// **'User registered: {voucher} for {clubName}'**
  String userRegisteredFor(String voucher, String clubName);

  /// No description provided for @enterUserUUID.
  ///
  /// In en, this message translates to:
  /// **'Enter user UUID'**
  String get enterUserUUID;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @kidsInClub.
  ///
  /// In en, this message translates to:
  /// **'Kids in club'**
  String get kidsInClub;

  /// No description provided for @noKidsInClub.
  ///
  /// In en, this message translates to:
  /// **'No kids in this club'**
  String get noKidsInClub;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @useThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get useThisPhoto;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @takeNext.
  ///
  /// In en, this message translates to:
  /// **'Take next'**
  String get takeNext;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// No description provided for @startCamera.
  ///
  /// In en, this message translates to:
  /// **'Start camera'**
  String get startCamera;

  /// No description provided for @attendanceRecorded.
  ///
  /// In en, this message translates to:
  /// **'Attendance recorded'**
  String get attendanceRecorded;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get finishSession;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @recognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognize face'**
  String get recognizing;

  /// No description provided for @checkAttendanceFor.
  ///
  /// In en, this message translates to:
  /// **'Check attendance for {name}'**
  String checkAttendanceFor(String name);

  /// No description provided for @takePhotoToRecognize.
  ///
  /// In en, this message translates to:
  /// **'Take a photo to recognize this student'**
  String get takePhotoToRecognize;

  /// No description provided for @notRecognized.
  ///
  /// In en, this message translates to:
  /// **'Not recognized'**
  String get notRecognized;

  /// No description provided for @studentPresent.
  ///
  /// In en, this message translates to:
  /// **'Student present'**
  String get studentPresent;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @organizations.
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get organizations;

  /// No description provided for @noOrganizations.
  ///
  /// In en, this message translates to:
  /// **'No organizations available'**
  String get noOrganizations;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @noCourses.
  ///
  /// In en, this message translates to:
  /// **'No courses available'**
  String get noCourses;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @noClasses.
  ///
  /// In en, this message translates to:
  /// **'No classes available'**
  String get noClasses;

  /// No description provided for @photoFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get photoFront;

  /// No description provided for @photoLeft.
  ///
  /// In en, this message translates to:
  /// **'Left 30°'**
  String get photoLeft;

  /// No description provided for @photoRight.
  ///
  /// In en, this message translates to:
  /// **'Right 30°'**
  String get photoRight;

  /// No description provided for @photoFrontHint.
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera'**
  String get photoFrontHint;

  /// No description provided for @photoLeftHint.
  ///
  /// In en, this message translates to:
  /// **'Turn head left ~30°'**
  String get photoLeftHint;

  /// No description provided for @photoRightHint.
  ///
  /// In en, this message translates to:
  /// **'Turn head right ~30°'**
  String get photoRightHint;

  /// No description provided for @photoTips.
  ///
  /// In en, this message translates to:
  /// **'Good lighting, face fully visible, neutral background, no glasses if possible'**
  String get photoTips;

  /// No description provided for @guidedPhotoCapture.
  ///
  /// In en, this message translates to:
  /// **'Guided photo capture'**
  String get guidedPhotoCapture;

  /// No description provided for @guidedPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-captures when pose is held for 1 second'**
  String get guidedPhotoSubtitle;

  /// No description provided for @holdSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold steady...'**
  String get holdSteady;

  /// No description provided for @photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured!'**
  String get photoCaptured;

  /// No description provided for @faceNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Face not detected'**
  String get faceNotDetected;

  /// No description provided for @wrongPose.
  ///
  /// In en, this message translates to:
  /// **'Adjust your pose'**
  String get wrongPose;

  /// No description provided for @allPhotosCaptured.
  ///
  /// In en, this message translates to:
  /// **'All 3 photos captured'**
  String get allPhotosCaptured;

  /// No description provided for @nOfThreePhotos.
  ///
  /// In en, this message translates to:
  /// **'{n} of 3 photos'**
  String nOfThreePhotos(int n);

  /// No description provided for @updatePhotos.
  ///
  /// In en, this message translates to:
  /// **'Update photos'**
  String get updatePhotos;

  /// No description provided for @updatePhotosFor.
  ///
  /// In en, this message translates to:
  /// **'Update photos for {name}'**
  String updatePhotosFor(String name);

  /// No description provided for @photosUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photos updated successfully'**
  String get photosUpdated;

  /// No description provided for @photosRejected.
  ///
  /// In en, this message translates to:
  /// **'Photo update rejected: identity mismatch'**
  String get photosRejected;

  /// No description provided for @noPhotosRegistered.
  ///
  /// In en, this message translates to:
  /// **'No photos registered'**
  String get noPhotosRegistered;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @recognizeFace.
  ///
  /// In en, this message translates to:
  /// **'Recognize face'**
  String get recognizeFace;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get attendanceHistory;

  /// No description provided for @noAttendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'No attendance history'**
  String get noAttendanceHistory;

  /// No description provided for @recognitionHistory.
  ///
  /// In en, this message translates to:
  /// **'Recognition history'**
  String get recognitionHistory;

  /// No description provided for @noRecognitionHistory.
  ///
  /// In en, this message translates to:
  /// **'No recognition history'**
  String get noRecognitionHistory;

  /// No description provided for @recognized.
  ///
  /// In en, this message translates to:
  /// **'Recognized'**
  String get recognized;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
