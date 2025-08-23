import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'alphabets_screen.dart';
import 'words_screen.dart';
import 'sentences_screen.dart';
import 'zair_screen.dart';
import 'paish_screen.dart';
import 'settings_screen.dart';
import 'speech.dart';
import 'spch_test.dart';
import 'game.dart';
import 'chapter_list_screen.dart';
import 'ex_lstn_listing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nazra App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/listen': (context) => ChapterListScreen(),
        '/lstnex': (context) => ExLstnListing(),
        //'/words': (context) => CompoundScreen(),
        //'/sentences': (context) => ZabarScreen(),
        //'/zair': (context) => ZairScreen(),
       // '/paish': (context) => PaishScreen(),
        '/speech': (context) => ArabicSpeakingCheck(xmlFilePath: 'assets/spchtest.xml'),
        '/sptest': (context) => SpeechScreen(),
        //'/game': (context) => LetterGameScreen(),
        //'/settings': (context) => SettingsScreen(),
      },
    );
  }
}
