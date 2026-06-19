import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_storage_service.dart';
import 'core/services/locale_storage_service.dart';
import 'core/l10n/app_locale_scope.dart';
import 'generated/l10n/app_localizations.dart';
import 'features/attendance/screens/home_screen.dart';
import 'features/camera/bloc/camera_bloc/camera_bloc.dart';
import 'features/camera/bloc/flow_bloc/camera_flow_bloc.dart';
import 'features/camera/screens/camera_screen.dart';
import 'core/services/face_recognition_service.dart';
import 'features/clubs/bloc/club_bloc.dart';
import 'features/clubs/bloc/organization_bloc.dart';
import 'features/report_cards/bloc/report_card_bloc.dart';
import 'features/face_recognition/bloc/face_recognition_bloc.dart';
import 'features/settings/bloc/auth_bloc.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleStorageService _localeStorage = LocaleStorageService();
  Locale? _locale;
  late final AuthStorageService _authStorageService;
  late final ApiService _apiService;
  late final FaceRecognitionService _faceRecognitionService;

  @override
  void initState() {
    super.initState();
    _authStorageService = AuthStorageService();
    _apiService = ApiService(storageService: _authStorageService);
    _faceRecognitionService = FaceRecognitionService();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final code = await _localeStorage.getLocale();
    if (code != null && mounted) {
      setState(() => _locale = Locale(code));
    }
  }

  void _setLocale(Locale? locale) async {
    if (locale != null) {
      await _localeStorage.saveLocale(locale.languageCode);
    }
    if (mounted) {
      setState(() => _locale = locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            apiService: _apiService,
            storageService: _authStorageService,
          )..add(LoadUser()),
        ),
        BlocProvider(
          create: (context) => ClubBloc(apiService: _apiService),
        ),
        BlocProvider(
          create: (context) => ReportCardBloc(apiService: _apiService),
        ),
        BlocProvider(
          create: (context) => OrganizationBloc(apiService: _apiService)
            ..add(const LoadOrganizations()),
        ),
        BlocProvider(
          create: (context) => CameraBloc(),
        ),
        BlocProvider(
          create: (context) => CameraFlowBloc(
            apiService: _apiService,
            faceRecognitionService: _faceRecognitionService,
            authStorage: _authStorageService,
          ),
        ),
        BlocProvider(
          create: (context) => FaceRecognitionBloc(
            service: _faceRecognitionService,
          ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _apiService),
          RepositoryProvider.value(value: _authStorageService),
        ],
        child: AppLocaleScope(
          locale: _locale,
          setLocale: _setLocale,
          child: MaterialApp(
            title: _locale?.languageCode == 'ru' ? 'Учёт посещаемости' : 'Attendance Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: _locale,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => current is! AuthLoading,
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _initialLoadDone = false;
  final _cameraKey = GlobalKey<CameraScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    CameraScreen(key: _cameraKey),
    const SettingsScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      context.read<ReportCardBloc>().add(LoadReportCards());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            _cameraKey.currentState?.reinitIfNeeded();
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt),
            label: l10n.camera,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
