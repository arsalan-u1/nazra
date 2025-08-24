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
  State<ArabicSpeakingCheck> createState() => _ArabicSpeakingCheckState();
}

class _ArabicSpeakingCheckState extends State<ArabicSpeakingCheck> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  String displayedArabic = "";
  String userSpoken = "";
  String feedback = "";
  Color feedbackColor = Colors.transparent;

  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _loadXmlAndPickRandomText();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ar");
    await flutterTts.awaitSpeakCompletion(true);
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
        userSpoken = '';
        feedback = '';
        feedbackColor = Colors.transparent;
      });
    } catch (e) {
      debugPrint("Error loading XML: $e");
    }
  }

  Future<void> _startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );

    if (!available) {
      debugPrint("Speech recognition not available");
      return;
    }

    setState(() {
      isListening = true;
      feedback = '';
      feedbackColor = Colors.transparent;
    });

    await speech.listen(
      localeId: 'ar-SA',
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            userSpoken = result.recognizedWords.trim();
            bool isCorrect = userSpoken == displayedArabic;

            feedback = isCorrect ? "أحسنت!" : "حاول مرة أخرى";
            feedbackColor = isCorrect ? Colors.green : Colors.red;

            flutterTts.speak(feedback);
          });
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await speech.stop();
    setState(() => isListening = false);
  }

  Future<void> _repeatWord() async {
    await flutterTts.speak(displayedArabic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arabic Speaking Check"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              displayedArabic,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isListening ? _stopListening : _startListening,
              child: Text(isListening ? "Stop Listening" : "Start Speaking"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _repeatWord,
              child: const Text("Repeat Word"),
            ),
            const SizedBox(height: 20),
            Text(
              "You said: $userSpoken",
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              feedback,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: feedbackColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loadXmlAndPickRandomText,
              child: const Text("Next Word"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }
}