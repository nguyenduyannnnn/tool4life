import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

import 'common/config.dart';
import 'common/globals.dart';
import 'common/localization/l10n.dart';
import 'common/theme.dart';
import 'common/utilities.dart';
import 'features/todo/data/datasources/local_database_service.dart';
import 'presentation/modules/authen_module/src/ui/splash_screen.dart';
import 'recording/services/file_manager_service.dart';
import 'recording/services/migration_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Config.getPreferences().then((_) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Initialize local SQLite database (used by Todo feature)
    try {
      await LocalDatabaseService.instance.open();
    } catch (e) {
      Utilities.customPrint('Error opening local database: $e');
    }

    // Initialize FileManagerService and scan for existing recordings
    _initializeRecordingServices();

    Globals.myApp = GlobalKey<MyAppState>();
    runApp(MyApp(
      key: Globals.myApp,
    ));
  });
}

// Initialize recording services
Future<void> _initializeRecordingServices() async {
  try {
    final migrationService = MigrationService();
    final fileManagerService = FileManagerService();
    
    // First, migrate any existing recordings to Chang Meeting folder
    await migrationService.migrateRecordingsToMeobeoFolder();
    
    // Then scan and initialize recordings
    await fileManagerService.initializeAndScanRecordings();
    
    Utilities.customPrint('📁 Recording services initialized successfully');
  } catch (e) {
    Utilities.customPrint('❌ Error initializing recording services: $e');
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget? child;

  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    child = SplashScreen();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  onRefresh() async {
    await Config.getPreferences();
    _key = GlobalKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: MaterialApp(
          key: _key,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return Container();
            };
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: GestureDetector(
                  onTap: Utilities.hideKeyboard,
                  child: child!,
                ));
          },
          locale: const Locale('en', 'US'), // Tạm thời sử dụng tiếng Anh
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('vi', 'VN'),
          ],
          localizationsDelegates: [
            // A class which loads the translations from JSON files
            LangKey.delegate,
            // Built-in localization of basic text for Material widgets
            // GlobalMaterialLocalizations.delegate,
            // Built-in localization for text direction LTR/RTL
            // GlobalWidgetsLocalizations.delegate,

            // GlobalCupertinoLocalizations.delegate
          ],
          home: child,
        ),
      ),
    );
  }
}
