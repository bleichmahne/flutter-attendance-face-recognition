// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Attendance Tracker';

  @override
  String get home => 'Home';

  @override
  String get register => 'Register';

  @override
  String get camera => 'Camera';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get searchUserByUuid => 'Search user by UUID';

  @override
  String get userImageRecognition => 'User image recognition';

  @override
  String get userImageRecognitionSubtitle => '3 photos, club, voucher';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get clubsAndReportCards => 'Clubs & Report Cards';

  @override
  String get clubs => 'Clubs';

  @override
  String get reportCards => 'Report Cards';

  @override
  String get all => 'All';

  @override
  String get noClubsAvailable => 'No clubs available';

  @override
  String get noReportCards => 'No report cards';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get clubsAndReportCardsEmptyHint =>
      'Clubs and report cards will appear here';

  @override
  String get retry => 'Retry';

  @override
  String get take3PicturesOfUser => 'Take 3 pictures of user';

  @override
  String get take3PhotosInSequence => 'Take 3 photos in sequence';

  @override
  String photoNOf3(int n) {
    return 'Photo $n of 3...';
  }

  @override
  String get orTapBoxToTakeOrReplace =>
      'Or tap a box to take or replace that photo';

  @override
  String photoN(int n) {
    return 'Photo $n';
  }

  @override
  String get selectClub => 'Select club';

  @override
  String get chooseClub => 'Choose club';

  @override
  String get voucherNumber => 'Voucher number';

  @override
  String get enterVoucherNumber => 'Enter voucher number';

  @override
  String get clearImages => 'Clear images';

  @override
  String get submit => 'Submit';

  @override
  String userRegisteredFor(String voucher, String clubName) {
    return 'User registered: $voucher for $clubName';
  }

  @override
  String get enterUserUUID => 'Enter user UUID';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get kidsInClub => 'Kids in club';

  @override
  String get noKidsInClub => 'No kids in this club';

  @override
  String get age => 'Age';

  @override
  String get useThisPhoto => 'Use this photo';

  @override
  String get retake => 'Retake';

  @override
  String get takeNext => 'Take next';

  @override
  String get done => 'Done';

  @override
  String get present => 'Present';

  @override
  String get missing => 'Missing';

  @override
  String get startCamera => 'Start camera';

  @override
  String get attendanceRecorded => 'Attendance recorded';

  @override
  String get finishSession => 'Finish session';

  @override
  String get summary => 'Summary';

  @override
  String get recognizing => 'Recognize face';

  @override
  String checkAttendanceFor(String name) {
    return 'Check attendance for $name';
  }

  @override
  String get takePhotoToRecognize => 'Take a photo to recognize this student';

  @override
  String get notRecognized => 'Not recognized';

  @override
  String get studentPresent => 'Student present';

  @override
  String get reset => 'Reset';

  @override
  String get organizations => 'Organizations';

  @override
  String get noOrganizations => 'No organizations available';

  @override
  String get courses => 'Courses';

  @override
  String get noCourses => 'No courses available';

  @override
  String get classes => 'Classes';

  @override
  String get noClasses => 'No classes available';

  @override
  String get photoFront => 'Front';

  @override
  String get photoLeft => 'Left 30°';

  @override
  String get photoRight => 'Right 30°';

  @override
  String get photoFrontHint => 'Look straight at the camera';

  @override
  String get photoLeftHint => 'Turn head left ~30°';

  @override
  String get photoRightHint => 'Turn head right ~30°';

  @override
  String get photoTips =>
      'Good lighting, face fully visible, neutral background, no glasses if possible';

  @override
  String get guidedPhotoCapture => 'Guided photo capture';

  @override
  String get guidedPhotoSubtitle =>
      'Auto-captures when pose is held for 1 second';

  @override
  String get holdSteady => 'Hold steady...';

  @override
  String get photoCaptured => 'Photo captured!';

  @override
  String get faceNotDetected => 'Face not detected';

  @override
  String get wrongPose => 'Adjust your pose';

  @override
  String get allPhotosCaptured => 'All 3 photos captured';

  @override
  String nOfThreePhotos(int n) {
    return '$n of 3 photos';
  }

  @override
  String get updatePhotos => 'Update photos';

  @override
  String updatePhotosFor(String name) {
    return 'Update photos for $name';
  }

  @override
  String get photosUpdated => 'Photos updated successfully';

  @override
  String get photosRejected => 'Photo update rejected: identity mismatch';

  @override
  String get noPhotosRegistered => 'No photos registered';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get recognizeFace => 'Recognize face';

  @override
  String get attendanceHistory => 'Attendance history';

  @override
  String get noAttendanceHistory => 'No attendance history';

  @override
  String get recognitionHistory => 'Recognition history';

  @override
  String get noRecognitionHistory => 'No recognition history';

  @override
  String get recognized => 'Recognized';

  @override
  String get confidence => 'Confidence';
}
