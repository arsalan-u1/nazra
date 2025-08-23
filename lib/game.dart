import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class LetterGameScreen extends StatefulWidget {
  const LetterGameScreen({super.key});

  @override
  _LetterGameScreenState createState() => _LetterGameScreenState();
}

class _LetterGameScreenState extends State<LetterGameScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, String>> alphabets = [];
  String correctLetter = "";
  List<Map<String, String>> displayedLetters = [];
  String feedbackMessage = "";
  Color feedbackColor = Colors.transparent;

  String selectedXmlFile = 'assets/alphabet.xml'; // Default XML file
  Set<int> pressedIndices = {};
  Map<int, Color> animatedBoxColors = {};

  @override
  void initState() {
    super.initState();
    _loadAlphabetsFromXml(selectedXmlFile);
  }

  Future<void> _loadAlphabetsFromXml(String xmlPath) async {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    try {
      String xmlString = await rootBundle.loadString(xmlPath);
      var document = xml.XmlDocument.parse(xmlString);
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
      Colors.black ,
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
      feedbackMessage = ""; // Well done!
      //feedbackColor = Colors.green;
    });
  }
  void _speakAgain() async {
    await flutterTts.setLanguage("ar");
    await flutterTts.awaitSpeakCompletion(true); // Ensure TTS waits for speech completion
    await flutterTts.speak(correctLetter);
  }
  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ar");
    await flutterTts.speak(text);
  }

  void _checkAnswer(String selectedLetter, int index) async {
    bool isCorrect = selectedLetter == correctLetter;

    setState(() {
      animatedBoxColors[index] = isCorrect ? Colors.green : Colors.redAccent;
      feedbackMessage = isCorrect ? "أحسنت!" : "حاول مرة أخرى";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    await flutterTts.setLanguage("ar");
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(feedbackMessage);

    await flutterTts.setLanguage("en-US");
    await flutterTts.awaitSpeakCompletion(true);
    await Future.delayed(Duration(milliseconds: 200));
    await flutterTts.speak(isCorrect ? "Well Done" : "Try again");

    if (!isCorrect) {
      await flutterTts.setLanguage("ar");
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.speak(correctLetter);
    }

    // Reset the box color after delay
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        animatedBoxColors[index] = Colors.blue.shade200;
      });
    });

    if (isCorrect) {
      await Future.delayed(Duration(seconds: 1));
      _setNewQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Noorani Qaida Exercise"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedXmlFile,
              items: [
                {'label': 'Single Letters', 'value':'assets/alphabet.xml'},
    {'label': 'Compound Letters', 'value':'assets/compound.xml'},
    {'label': 'Paish Easy', 'value':'assets/paish.xml'},
    {'label': 'Paish Hard', 'value':'assets/paish2.xml'},
    {'label': 'Zabar Easy', 'value':'assets/zabar.xml'},
    {'label': 'Zabar Hard', 'value':'assets/zabar2.xml'},
    {'label': 'Zair Easy', 'value':'assets/zair.xml'},
    {'label': 'Zair Hard', 'value':'assets/zair2.xml'},
              ].map((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!), // Display user-friendly label
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedXmlFile = newValue!;
                  _loadAlphabetsFromXml(selectedXmlFile);
                });
              },
            ),
            SizedBox(height: 20),
            Text("Listen carefully and select the correct letter", textAlign: TextAlign.center),
            SizedBox(height: 20),
            if (displayedLetters.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: displayedLetters.length,
                itemBuilder: (context, index) {
                  String arabicLetter = displayedLetters[index]["arabic"]!;
                  bool isPressed = pressedIndices.contains(index);
                  Color baseColor = animatedBoxColors[index] ?? Colors.blue.shade200;
                  Color tileColor = isPressed ? Colors.red : baseColor;

                  return GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        pressedIndices.add(index);
                      });
                    },
                    onTapUp: (_) {
                      Future.delayed(Duration(milliseconds: 150), () {
                        setState(() {
                          pressedIndices.remove(index);
                        });
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        pressedIndices.remove(index);
                      });
                    },
                    onTap: () => _checkAnswer(arabicLetter, index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
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
            SizedBox(height: 20),
            Text(
              feedbackMessage,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: feedbackColor),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speakAgain,
              child: Text("Speak Again"),
            ),
          ],
        ),
      ),
    );
  }
}
