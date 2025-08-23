import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:xml/xml.dart' as xml;

class ChapterDetailScreen extends StatefulWidget {
  final String filePath; // The XML file to load

  const ChapterDetailScreen({super.key, required this.filePath});

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, String>> alphabets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setTtsSettings();
    _loadFromXml(widget.filePath);
  }

  Future<void> _setTtsSettings() async {
    //await flutterTts.setPitch(1.0);
   // await flutterTts.setSpeechRate(0.2);
    await flutterTts.setLanguage("ar");
    // Set a default engine
    await flutterTts.setEngine("com.google.android.tts");
    // Set a voice (if needed)
    await flutterTts.setVoice({"name": "ar-xa-x-arz-local", "locale": "ar"});
    await flutterTts.awaitSpeakCompletion(true); // Ensure TTS waits for speech completion


    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text, {String language = "ar"}) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }

  Future<void> _loadFromXml(String path) async {
    try {
      String xmlString = await rootBundle.loadString(path);
      var document = xml.XmlDocument.parse(xmlString);

      setState(() {
        alphabets = document.findAllElements('letter').map((node) {
          return {
            "arabic": node.getAttribute('arabic') ?? "",
            "arabic2": node.getAttribute('arabic2') ?? "",
            "english": node.getAttribute('english') ?? "",
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading XML: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapterName = widget.filePath.split('/').last.replaceAll('.xml', '');

    return Scaffold(
      appBar: AppBar(
        title: Text(chapterName, textDirection: TextDirection.ltr),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : alphabets.isEmpty
          ? const Center(child: Text("No data found in XML"))
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: GridView.builder(
            itemCount: alphabets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return AlphabetTile(
                arabicLetter: alphabets[index]["arabic"]!,
                englishCaption: alphabets[index]["english"]!,
                //onTap: () => _speak(alphabets[index]["arabic2"]!, language: "ar"),
                onTap: () => _speak(
                  (alphabets[index]["arabic2"]?.isNotEmpty ?? false)
                      ? alphabets[index]["arabic2"]!
                      : alphabets[index]["arabic"]!,
                  language: "ar",
                )
              );
            },
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

  const AlphabetTile({
    super.key,
    required this.arabicLetter,
    required this.englishCaption,
    required this.onTap,
  });

  @override
  State<AlphabetTile> createState() => _AlphabetTileState();
}

class _AlphabetTileState extends State<AlphabetTile> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isTapped = true),
      onTapUp: (_) async {
        await widget.onTap();
        setState(() => isTapped = false);
      },
      onTapCancel: () => setState(() => isTapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isTapped ? Colors.red : Colors.blue.shade200,
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
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.englishCaption,
              style: const TextStyle(
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