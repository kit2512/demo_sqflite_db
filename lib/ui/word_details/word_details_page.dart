import 'package:demo_app/data/models.dart';
import 'package:flutter/material.dart';

class WordDetailsPage extends StatefulWidget {
  const WordDetailsPage({
    super.key,
    required this.word,
  });

  final WordModel word;

  @override
  State<WordDetailsPage> createState() => _WordDetailsPageState();

  static MaterialPageRoute<WordModel> route(WordModel word) {
    return MaterialPageRoute<WordModel>(
      builder: (_) => WordDetailsPage(
        word: word,
      ),
    );
  }
}

class _WordDetailsPageState extends State<WordDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Details'),
      ),
    );
  }
}
