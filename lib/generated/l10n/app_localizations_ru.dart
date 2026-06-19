// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Учёт посещаемости';

  @override
  String get home => 'Главная';

  @override
  String get register => 'Регистрация';

  @override
  String get camera => 'Камера';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get searchUserByUuid => 'Поиск пользователя по UUID';

  @override
  String get userImageRecognition => 'Распознавание по фото';

  @override
  String get userImageRecognitionSubtitle => '3 фото, клуб, ваучер';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirmTitle => 'Выход';

  @override
  String get logoutConfirmMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get cancel => 'Отмена';

  @override
  String get changeLanguage => 'Изменить язык';

  @override
  String get language => 'Язык';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get clubsAndReportCards => 'Клубы и отчёты';

  @override
  String get clubs => 'Клубы';

  @override
  String get reportCards => 'Отчёты';

  @override
  String get all => 'Всё';

  @override
  String get noClubsAvailable => 'Нет доступных клубов';

  @override
  String get noReportCards => 'Нет отчётов';

  @override
  String get noDataAvailable => 'Нет данных';

  @override
  String get clubsAndReportCardsEmptyHint => 'Клубы и отчёты появятся здесь';

  @override
  String get retry => 'Повторить';

  @override
  String get take3PicturesOfUser => 'Сделайте 3 фото пользователя';

  @override
  String get take3PhotosInSequence => 'Сделать 3 фото по очереди';

  @override
  String photoNOf3(int n) {
    return 'Фото $n из 3...';
  }

  @override
  String get orTapBoxToTakeOrReplace =>
      'Или нажмите на ячейку, чтобы сделать или заменить фото';

  @override
  String photoN(int n) {
    return 'Фото $n';
  }

  @override
  String get selectClub => 'Выберите клуб';

  @override
  String get chooseClub => 'Выберите клуб';

  @override
  String get voucherNumber => 'Номер ваучера';

  @override
  String get enterVoucherNumber => 'Введите номер ваучера';

  @override
  String get clearImages => 'Очистить фото';

  @override
  String get submit => 'Отправить';

  @override
  String userRegisteredFor(String voucher, String clubName) {
    return 'Пользователь зарегистрирован: $voucher для $clubName';
  }

  @override
  String get enterUserUUID => 'Введите UUID пользователя';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String get username => 'Имя пользователя';

  @override
  String get enterUsername => 'Введите имя пользователя';

  @override
  String get pleaseEnterUsername => 'Введите имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get pleaseEnterPassword => 'Введите пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get loginFailed => 'Ошибка входа';

  @override
  String get kidsInClub => 'Дети в клубе';

  @override
  String get noKidsInClub => 'В этом клубе нет детей';

  @override
  String get age => 'Возраст';

  @override
  String get useThisPhoto => 'Использовать фото';

  @override
  String get retake => 'Переснять';

  @override
  String get takeNext => 'Следующее';

  @override
  String get done => 'Готово';

  @override
  String get present => 'Присутствуют';

  @override
  String get missing => 'Отсутствуют';

  @override
  String get startCamera => 'Запустить камеру';

  @override
  String get attendanceRecorded => 'Посещаемость записана';

  @override
  String get finishSession => 'Завершить';

  @override
  String get summary => 'Итог';

  @override
  String get recognizing => 'Распознать лицо';

  @override
  String checkAttendanceFor(String name) {
    return 'Отметить посещаемость: $name';
  }

  @override
  String get takePhotoToRecognize => 'Сделайте фото для распознавания';

  @override
  String get notRecognized => 'Не распознан';

  @override
  String get studentPresent => 'Ученик присутствует';

  @override
  String get reset => 'Сброс';

  @override
  String get organizations => 'Организации';

  @override
  String get noOrganizations => 'Нет доступных организаций';

  @override
  String get courses => 'Курсы';

  @override
  String get noCourses => 'Нет доступных курсов';

  @override
  String get classes => 'Классы';

  @override
  String get noClasses => 'Нет доступных классов';

  @override
  String get photoFront => 'Анфас';

  @override
  String get photoLeft => 'Влево 30°';

  @override
  String get photoRight => 'Вправо 30°';

  @override
  String get photoFrontHint => 'Смотрите прямо в камеру';

  @override
  String get photoLeftHint => 'Поверните голову влево ~30°';

  @override
  String get photoRightHint => 'Поверните голову вправо ~30°';

  @override
  String get photoTips =>
      'Хорошее освещение, лицо полностью видно, нейтральный фон, без очков (если возможно)';

  @override
  String get guidedPhotoCapture => 'Управляемая съемка';

  @override
  String get guidedPhotoSubtitle => 'Автозахват при удержании позы 1 секунду';

  @override
  String get holdSteady => 'Не двигайтесь...';

  @override
  String get photoCaptured => 'Фото сделано!';

  @override
  String get faceNotDetected => 'Лицо не обнаружено';

  @override
  String get wrongPose => 'Скорректируйте позу';

  @override
  String get allPhotosCaptured => 'Все 3 фото сделаны';

  @override
  String nOfThreePhotos(int n) {
    return '$n из 3 фото';
  }

  @override
  String get updatePhotos => 'Обновить фото';

  @override
  String updatePhotosFor(String name) {
    return 'Обновить фото: $name';
  }

  @override
  String get photosUpdated => 'Фото успешно обновлены';

  @override
  String get photosRejected =>
      'Обновление фото отклонено: несовпадение личности';

  @override
  String get noPhotosRegistered => 'Фото не зарегистрированы';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get recognizeFace => 'Распознать лицо';

  @override
  String get attendanceHistory => 'История посещений';

  @override
  String get noAttendanceHistory => 'Нет истории посещений';

  @override
  String get recognitionHistory => 'История распознаваний';

  @override
  String get noRecognitionHistory => 'Нет истории распознаваний';

  @override
  String get recognized => 'Распознан';

  @override
  String get confidence => 'Уверенность';
}
