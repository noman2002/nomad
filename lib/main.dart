import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/firebase/auth/auth_gate.dart';
import 'app/firebase/firebase_bootstrap.dart';
import 'app/screens/home_shell.dart';
import 'app/state/chat_state.dart';
import 'app/state/nav_state.dart';
import 'app/state/quests_state.dart';
import 'app/state/session_state.dart';
import 'app/state/stories_state.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isTest = bool.fromEnvironment('FLUTTER_TEST');
  if (!isTest) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseBootstrap.configure();
  }

  runApp(MyApp(enableAuthGate: !isTest));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.enableAuthGate = true});

  final bool enableAuthGate;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavState()),
        ChangeNotifierProvider(create: (_) => SessionState()),
        ChangeNotifierProvider(create: (_) => StoriesState()),
        ChangeNotifierProvider(create: (_) => QuestsState()),
        ChangeNotifierProvider(create: (_) => ChatState()),
      ],
      child: MaterialApp(
        title: 'Nomad',
        theme: buildAppTheme(),
        home: enableAuthGate ? const AuthGate(child: HomeShell()) : const HomeShell(),
      ),
    );
  }
}
