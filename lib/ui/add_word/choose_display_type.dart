import 'package:demo_app/data/models.dart';
import 'package:demo_app/ui/add_word/add_word_screen.dart';
import 'package:flutter/material.dart';

class ChooseDisplayType extends StatefulWidget {
  const ChooseDisplayType({
    super.key,
    required this.package,
  });

  final PackageModel package;

  @override
  State<ChooseDisplayType> createState() => _ChooseDisplayTypeState();

  static MaterialPageRoute<WordModel> route(PackageModel package) => MaterialPageRoute<WordModel>(
        builder: (_) => ChooseDisplayType(
          package: package,
        ),
      );
}

class _ChooseDisplayTypeState extends State<ChooseDisplayType> {
  DisplayType _frontType = DisplayType.text;
  DisplayType _backType = DisplayType.text;

  void _next() async {
    final newWord = await Navigator.of(context).push<WordModel>(AddWordScreen.route(
      frontType: _frontType,
      packageId: widget.package.id,
      backType: _backType,
    ));
    if (newWord != null && mounted) {
      Navigator.of(context).pop(newWord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Word'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text('Front:'),
              Radio<DisplayType>(
                groupValue: _frontType,
                value: DisplayType.text,
                onChanged: (value) => setState(() => _frontType = value!),
              ),
              const Text('Text'),
              const SizedBox(
                width: 16,
              ),
              Radio<DisplayType>(
                groupValue: _frontType,
                value: DisplayType.image,
                onChanged: (value) => setState(() => _frontType = value!),
              ),
              const Text('Image'),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              const Text('Back:'),
              Radio<DisplayType>(
                groupValue: _backType,
                value: DisplayType.text,
                onChanged: (value) => setState(() => _backType = value!),
              ),
              const Text('Text'),
              const SizedBox(
                width: 16,
              ),
              Radio<DisplayType>(
                groupValue: _backType,
                value: DisplayType.image,
                onChanged: (value) => setState(() => _backType = value!),
              ),
              const Text('Image'),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          FilledButton(onPressed: _next, child: Text('Next'))
        ],
      ),
    );
  }
}
