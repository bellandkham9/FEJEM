
import 'package:adminfejem/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interface/admin/Post/post_provider.dart';
import 'interface/Home/chat/Chat_provider.dart';
import 'theme_Provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCMGFXl1Nf48YPBUfWzQtpyQbAptSQM1vM',
      appId: '1:675415810577:android:025eb3034c679b5b0bc7b0',
      messagingSenderId: '675415810577',
      projectId: 'fejemproject',
    ),
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
      ],
      child: Consumer<UiProvider>(
        builder: (context, uiProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NKUU',
          theme: uiProvider.isDark ? uiProvider.darkTheme : uiProvider.lightTheme,
          home:  const SplashScreen(),
        ),
      ),
    );
  }
}

