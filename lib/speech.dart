import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'dart:math';

class ArabicSpeakingCheck extends StatefulWidget {
  final String xmlFilePath;

  const ArabicSpeakingCheck({super.key, required this.xmlFilePath});

  @override
  _ArabicSpeakingCheckState createState() => _ArabicSpeakingCheckState();
}

class _ArabicSpeakingCheckState extends State<ArabicSpeakingCheck> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  String displayedArabic = "";
  //String chkArabic = "";
  String userSpoken = "";
  String feedback = "";
  Color feedbackColor = Colors.transparent;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Tap the mic to start listening...';

  @override
  void initState() {
    super.initState();
    _loadXmlAndPickRandomText();
    //_initSpeech();
    _speech = stt.SpeechToText();
  }

  Future<void> _loadXmlAndPickRandomText() async {
    try {
      final xmlString = await rootBundle.loadString(widget.xmlFilePath);
      final doc = XmlDocument.parse(xmlString);
      final letters = doc.findAllElements('letter').toList();

      if (letters.isEmpty) return;

      final randomLetter = letters[Random().nextInt(letters.length)];
      setState(() {
        displayedArabic = randomLetter.getAttribute('arabic2') ?? '';
        feedback = '';
        feedbackColor = Colors.transparent;
      });

      await flutterTts.setLanguage("ar");
      //await flutterTts.speak(displayedArabic);

    } catch (e) {
      print("Error loading or parsing XML: $e");
    }
  }

  /*Future<void> _initSpeech() async {
    await speech.initialize();
  }*/
  void _initSpeech() async {
    bool available = await speech.initialize();
    if (available) {
      var locales = await speech.locales();

      for (var locale in locales) {
        print("Locale: ${locale.localeId} - Name: ${locale.name}");
      }
    } else {
      print("Speech recognition not available.");
    }
  }
 /* void _startListening() async {
    setState(() {
      feedback = '';
      feedbackColor = Colors.transparent;
    });

    await speech.listen(
      localeId: 'ar_SA',
      onResult: (result) {
        setState(() {
          userSpoken = result.recognizedWords.trim();
          bool isCorrect = userSpoken == displayedArabic;

          feedback = isCorrect ? "أحسنت!" : "حاول مرة أخرى";
          feedbackColor = isCorrect ? Colors.green : Colors.red;

          flutterTts.setLanguage(isCorrect ? "en-US" : "ar");
          flutterTts.speak(feedback);
        });
      },
    );
  }*/
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('STATUS: $val'),
        onError: (val) => print('ERROR: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
          localeId: 'ar-SA',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (!available) {
      print("Speech recognition not available");
      return;
    }

    print("Starting to listen...");
    await speech.listen(
      localeId: 'ar-SA',
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            userSpoken = result.recognizedWords.trim();
            bool isCorrect = userSpoken == displayedArabic;

            feedback = isCorrect ? "أحسنت!" : "حاول مرة أخرى";
            feedbackColor = isCorrect ? Colors.green : Colors.red;

            //flutterTts.setLanguage(isCorrect ? "en-US" : "ar");
            flutterTts.speak(feedback);
          });
        }
      },
    );
  }
  void _stopListening() async {
    await speech.stop();
  }

  void _speakAgain() async {
    await flutterTts.setLanguage("ar");
    await flutterTts.speak(displayedArabic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Arabic Speaking Check"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              displayedArabic,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startListening,
              child: Text("Start Speaking"),
            ),
            /*ElevatedButton(
              onPressed: _stopListening,
              child: Text("Stop Listening"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speakAgain,
              child: Text("Repeat Word"),
            ),
            SizedBox(height: 40),*/
            Text(
              "You said: $userSpoken",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              feedback,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: feedbackColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loadXmlAndPickRandomText,
              child: Text("Next Word"),
            ),
          ],
        ),
      ),
    );
  }
}
