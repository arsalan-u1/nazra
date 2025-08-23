import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;

class AlphabetsScreen extends StatelessWidget {
  const AlphabetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArabicAlphabetScreen(),
    );
  }
}

class ArabicAlphabetScreen extends StatefulWidget {
  const ArabicAlphabetScreen({super.key});

  @override
  _ArabicAlphabetScreenState createState() => _ArabicAlphabetScreenState();
}

class _ArabicAlphabetScreenState extends State<ArabicAlphabetScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, String>> alphabets = [];

  final String introTextEnglish =
      "In the Name of Allah, Most Gracious, Most Merciful.\nTotal Mufridaat Letters are 29. Amongst these 29 letters, there are 7 that are always pronounced with a thicker voice, these letters are called Mustaliyah Letters.\nExample";
  final String introTextArabic = "خ , ص , ض ,  ط , ظ , غ , ق";
  final String introTextEnglish2 = "Tap on any letters below to hear its pronunciation";

  @override
  void initState() {
    super.initState();
    _setTtsSettings();
    _loadAlphabetsFromXml();
    _speakIntro();
  }

  Future<void> _setTtsSettings() async {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text, {String language = "en-US"}) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }

  Future<void> _speakIntro() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.awaitSpeakCompletion(true); // Ensure TTS waits for speech completion

    // Ensure TTS is ready before speaking English
    await flutterTts.setSpeechRate(0.5); // Adjust Arabic speech rate separately
    await Future.delayed(Duration(milliseconds: 500)); // Small delay for TTS initialization
    await flutterTts.speak(introTextEnglish);
    await flutterTts.awaitSpeakCompletion(true); // Wait for English to complete

    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.2); // Adjust Arabic speech rate separately
    await Future.delayed(Duration(milliseconds: 500)); // Small delay for smooth transition
    await flutterTts.speak(introTextArabic);
    await flutterTts.awaitSpeakCompletion(true);

    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5); // Adjust Arabic speech rate separately
    await Future.delayed(Duration(milliseconds: 500)); // Small delay for smooth transition
    await flutterTts.speak(introTextEnglish2);
    await flutterTts.awaitSpeakCompletion(true);

    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.4); // Reset Arabic speech rate after completion
  }

  Future<void> _loadAlphabetsFromXml() async {
    try {
      String xmlString = await rootBundle.loadString('assets/alphabet.xml');
      var document = xml.XmlDocument.parse(xmlString);
      setState(() {
        alphabets = document.findAllElements('letter').map((node) {
          return {
            "arabic": node.getAttribute('arabic') ?? "",
            "english": node.getAttribute('english') ?? "",
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
                    SizedBox(height: 10),
                    Text(
                      introTextArabic,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 10),
                    Text(
                      introTextEnglish2,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
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
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return AlphabetTile(
                      arabicLetter: alphabets[index]["arabic"]!,
                      englishCaption: alphabets[index]["english"]!,
                      onTap: () => _speak(alphabets[index]["arabic"]!, language: "ar"),
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
  final String englishCaption;
  final Function onTap;

  const AlphabetTile({super.key, required this.arabicLetter, required this.englishCaption, required this.onTap});

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
            SizedBox(height: 5),
            Text(
              widget.englishCaption,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
