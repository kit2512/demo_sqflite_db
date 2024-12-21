import 'package:demo_app/data/database.dart';
import 'package:demo_app/data/models.dart';
import 'package:demo_app/ui/add_word/choose_display_type.dart';
import 'package:demo_app/ui/word_details/word_details_page.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key, required this.package});

  final PackageModel package;

  @override
  State<WordListScreen> createState() => _WordListScreenState();

  static MaterialPageRoute<void> route(PackageModel package) {
    return MaterialPageRoute<void>(
      builder: (_) => WordListScreen(
        package: package,
      ),
    );
  }
}

class _WordListScreenState extends State<WordListScreen> {
  List<WordModel> _words = [];

  FormzSubmissionStatus _getWordsStatus = FormzSubmissionStatus.initial;
  Future<void> _getWords() async {
    try {
      setState(() {
        _getWordsStatus = FormzSubmissionStatus.inProgress;
        _words = [];
      });
      final data = await AppDatabase.instance.getWords(widget.package.id);
      setState(() {
        _getWordsStatus = FormzSubmissionStatus.success;
        _words = data;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _getWordsStatus = FormzSubmissionStatus.failure;
        _words = [];
      });
    }
  }

  Future<void> _addWord() async {
    final newWord = await Navigator.of(context).push<WordModel>(ChooseDisplayType.route(widget.package));
    if (newWord != null) {
      setState(() {
        _words.add(newWord);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getWords();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.package.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addWord,
            )
          ],
        ),
        body: Builder(
          builder: (context) {
            if (_getWordsStatus.isFailure) {
              return Center(
                child: Column(
                  children: [
                    const Text('Unable to get words'),
                    const SizedBox(
                      height: 16,
                    ),
                    FilledButton(onPressed: _getWords, child: const Text('Retry'))
                  ],
                ),
              );
            }
            if (_getWordsStatus.isSuccess) {
              return ListView.builder(
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  final word = _words[index];
                  return ListTile(
                    title: Text(word.front),
                    subtitle: Text(word.back),
                    onTap: () => Navigator.of(context).push(WordDetailsPage.route(word)),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          },
        ),
      );
}
