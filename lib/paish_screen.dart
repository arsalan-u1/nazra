import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;

class PaishScreen extends StatelessWidget {
  const PaishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArabicPaishScreen(),
    );
  }
}

class ArabicPaishScreen extends StatefulWidget {
  const ArabicPaishScreen({super.key});

  @override
  _ArabicPaishScreenState createState() => _ArabicPaishScreenState();
}

class _ArabicPaishScreenState extends State<ArabicPaishScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, String>> alphabets = [];
  List<Map<String, String>> alphabets2 = [];

  final String introTextEnglish = "Sound of Paish";
  final String introTextArabic = "اُ";

  @override
  void initState() {
    super.initState();
    _setTtsSettings();
    _loadAlphabetsFromXml();
    _loadAlphabets2FromXml();
    _speakIntro();
  }

  Future<void> _setTtsSettings() async {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text, {String language = "ar"}) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }

  Future<void> _speakIntro() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.awaitSpeakCompletion(true); // Ensure TTS waits for speech completion

    // Ensure TTS is ready before speaking English
    await flutterTts.setSpeechRate(0.5); // Adjust Arabic speech rate separately
    //await Future.delayed(Duration(milliseconds: 500)); // Small delay for TTS initialization
    await flutterTts.speak(introTextEnglish);
    await flutterTts.awaitSpeakCompletion(true); // Wait for English to complete

    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.2); // Adjust Arabic speech rate separately
    //await Future.delayed(Duration(milliseconds: 500)); // Small delay for smooth transition
    await flutterTts.speak(introTextArabic);
    await flutterTts.awaitSpeakCompletion(true);

    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.2); // Reset Arabic speech rate after completion
  }

  Future<void> _loadAlphabetsFromXml() async {
    try {
      String xmlString = await rootBundle.loadString('assets/paish.xml');
      var document = xml.XmlDocument.parse(xmlString);
      setState(() {
        alphabets = document.findAllElements('letter').map((node) {
          return {
            "arabic": node.getAttribute('arabic') ?? "",
            "arabic2": node.getAttribute('arabic2') ?? "",
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading XML: $e");
    }
  }

  Future<void> _loadAlphabets2FromXml() async {
    try {
      String xmlString = await rootBundle.loadString('assets/paish2.xml');
      var document2 = xml.XmlDocument.parse(xmlString);
      setState(() {
        alphabets2 = document2.findAllElements('letter').map((node) {
          return {
            "arabic": node.getAttribute('arabic') ?? "",
            "arabic2": node.getAttribute('arabic2') ?? "",
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading XML: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      introTextEnglish,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.ltr,
                    ),
                    Text(
                      introTextArabic,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: alphabets.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                  itemCount: alphabets.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    return AlphabetTile(
                      arabicLetter: alphabets[index]["arabic"]!,
                      onTap: () => _speak(alphabets[index]["arabic2"]!, language: "ar"),
                    );
                  },
                ),
              ),
              Expanded(
                child: alphabets2.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                  itemCount: alphabets2.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    return AlphabetTile(
                      arabicLetter: alphabets2[index]["arabic"]!,
                      onTap: () => _speak(alphabets2[index]["arabic2"]!, language: "ar"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlphabetTile extends StatefulWidget {
  final String arabicLetter;
  final Function onTap;

  const AlphabetTile({super.key, required this.arabicLetter, required this.onTap});

  @override
  _AlphabetTileState createState() => _AlphabetTileState();
}

class _AlphabetTileState extends State<AlphabetTile> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isTapped = true; // Change color on tap down
        });
      },
      onTapUp: (_) async {
        await widget.onTap();
        setState(() {
          isTapped = false; // Reset color after tap release
        });
      },
      onTapCancel: () {
        setState(() {
          isTapped = false; // Reset color if tap is canceled
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isTapped ? Colors.red : Colors.blue.shade200, // 🔴 On Tap, 🔵 Default
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.arabicLetter,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
