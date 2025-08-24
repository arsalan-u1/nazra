import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class ExLstnDetail extends StatefulWidget {
  final String filePath; // passed from previous screen

  const ExLstnDetail({super.key, required this.filePath});

  @override
  _ExLstnDetailState createState() => _ExLstnDetailState();
}

class _ExLstnDetailState extends State<ExLstnDetail> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, String>> alphabets = [];
  String correctLetter = "";
  List<Map<String, String>> displayedLetters = [];
  String feedbackMessage = "";
  Color feedbackColor = Colors.transparent;

  Set<int> pressedIndices = {};
  Map<int, Color> animatedBoxColors = {};

  @override
  void initState() {
    super.initState();
    _loadAlphabetsFromXml(widget.filePath);
  }

  Future<void> _loadAlphabetsFromXml(String xmlPath) async {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    try {
      String xmlString = await rootBundle.loadString(xmlPath);
      var document = xml.XmlDocument.parse(xmlString);
      if (!mounted) return; // Ensure widget is still in tree
      setState(() {
        alphabets = document.findAllElements('letter').map((node) {
          return {
            "arabic": node.getAttribute('arabic') ?? "",
            "english": node.getAttribute('english') ?? "",
          };
        }).toList();
        _setNewQuestion();
      });
    } catch (e) {
      print("Error loading XML: $e");
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.white,
      Colors.teal,
      Colors.purple,
      Colors.lightGreenAccent,
      Colors.black,
      Colors.cyanAccent,
      Colors.limeAccent,
    ];
    return colors[index % colors.length];
  }

  void _setNewQuestion() {
    if (alphabets.length < 4) return;
    displayedLetters = List.from(alphabets)..shuffle();
    displayedLetters = displayedLetters.sublist(0, 4);
    correctLetter = displayedLetters[Random().nextInt(4)]["arabic"]!;
    _speak(correctLetter);
    setState(() {
      feedbackMessage = "";
    });
  }

  Future<void> _speakAgain() async {
    await _safeSpeak(correctLetter, lang: "ar");
  }

  Future<void> _speak(String text) async {
    await _safeSpeak(text, lang: "ar");
  }

  /// Safe method to call TTS with mounted guard
  Future<void> _safeSpeak(String text, {String lang = "ar"}) async {
    if (!mounted) return;
    await flutterTts.setLanguage(lang);
    await flutterTts.awaitSpeakCompletion(true);
    if (!mounted) return; // check again before speaking
    await flutterTts.speak(text);
  }

  void _checkAnswer(String selectedLetter, int index) async {
    bool isCorrect = selectedLetter == correctLetter;

    if (!mounted) return;
    setState(() {
      animatedBoxColors[index] = isCorrect ? Colors.green : Colors.redAccent;
      feedbackMessage = isCorrect ? "أحسنت!" : "حاول مرة أخرى";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    // Speak feedback safely with mounted guard
    await _safeSpeak(feedbackMessage, lang: "ar");
    await _safeSpeak(isCorrect ? "Well Done" : "Try again", lang: "en-US");

    if (!isCorrect) {
      await _safeSpeak(correctLetter, lang: "ar");
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        animatedBoxColors[index] = Colors.blue.shade200;
      });
    });

    if (isCorrect) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _setNewQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filePath.split('/').last),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Listen carefully and select the correct letter",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (displayedLetters.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: displayedLetters.length,
                itemBuilder: (context, index) {
                  String arabicLetter = displayedLetters[index]["arabic"]!;
                  bool isPressed = pressedIndices.contains(index);
                  Color baseColor =
                      animatedBoxColors[index] ?? Colors.blue.shade200;
                  Color tileColor = isPressed ? Colors.red : baseColor;

                  return GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        pressedIndices.add(index);
                      });
                    },
                    onTapUp: (_) {
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (mounted) {
                          setState(() {
                            pressedIndices.remove(index);
                          });
                        }
                      });
                    },
                    onTapCancel: () {
                      if (mounted) {
                        setState(() {
                          pressedIndices.remove(index);
                        });
                      }
                    },
                    onTap: () => _checkAnswer(arabicLetter, index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: RichText(
                        text: TextSpan(
                          children: List.generate(arabicLetter.length, (i) {
                            return TextSpan(
                              text: arabicLetter[i],
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Amiri',
                                color: _getColorForIndex(i),
                              ),
                            );
                          }),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            Text(
              feedbackMessage,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: feedbackColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speakAgain,
              child: const Text("Speak Again"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop(); // stop speaking before plugin is released
    super.dispose();
  }
}