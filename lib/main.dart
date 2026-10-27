import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads.dart';
import 'app_state.dart';
import 'firebase_options.dart';
import 'guide_repository.dart';
import 'screens/intro_screen.dart';
import 'screens/shell.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {
    // Not configured yet: run on the bundled guides.
  }
  await initAds();

  final prefs = await SharedPreferences.getInstance();
  final state = AppState(
    prefs: prefs,
    repository: GuideRepository(firebaseReady: firebaseReady),
  );
  await state.load();
  runApp(ProcessPKApp(state: state));
}

class ProcessPKApp extends StatelessWidget {
  final AppState state;
  final bool useGoogleFonts;

  const ProcessPKApp({
    super.key,
    required this.state,
    this.useGoogleFonts = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'ProcessPK',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(state.lang, useGoogleFonts: useGoogleFonts),
          locale: Locale(state.lang),
          supportedLocales: const [Locale('en'), Locale('ur')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: state.introSeen ? const Shell() : const IntroScreen(),
        ),
      ),
    );
  }
}
