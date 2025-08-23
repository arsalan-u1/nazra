import 'package:flutter/material.dart';
import 'chapter_files.dart';
import 'chapter_detail_screen.dart';

class ChapterListScreen extends StatelessWidget {
  const ChapterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2, // makes buttons wider
          ),
          itemCount: chapterFiles.length,
          itemBuilder: (context, index) {
            final path = chapterFiles[index];
            final name = path.split('/').last.replaceAll('.xml', '');

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChapterDetailScreen(filePath: path),
                  ),
                );
              },
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}