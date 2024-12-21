import 'dart:io';

import 'package:demo_app/data/database.dart';
import 'package:demo_app/data/models.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key, required this.frontType, required this.backType, required this.packageId});

  final DisplayType frontType;
  final DisplayType backType;
  final String packageId;

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();

  static Route<WordModel> route({
    required DisplayType frontType,
    required DisplayType backType,
    required String packageId,
  }) {
    return MaterialPageRoute<WordModel>(
      builder: (_) => AddWordScreen(
        frontType: frontType,
        backType: backType,
        packageId: packageId,
      ),
    );
  }
}

class _AddWordScreenState extends State<AddWordScreen> {
  final TextEditingController _frontText = TextEditingController();
  final TextEditingController _backText = TextEditingController();

  FormzSubmissionStatus _submissionStatus = FormzSubmissionStatus.initial;

  void _submit() async {
    try {
      if (_frontText.text.isEmpty || _backText.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        setState(() {
          _submissionStatus = FormzSubmissionStatus.failure;
        });
        return;
      }
      setState(() {
        _submissionStatus = FormzSubmissionStatus.inProgress;
      });
      String front = _frontText.text;
      String back = _backText.text;

      if (widget.backType == DisplayType.image) {
        final backFile = File(back);
        final dir = await getApplicationDocumentsDirectory();
        final newPath = '${dir.path}/backFiles/${const Uuid().v4()}${backFile.path.split('.').last}';
        await backFile.copy(newPath);
        back = newPath;
      }

      if (widget.frontType == DisplayType.image) {
        final frontFile = File(back);
        final dir = await getApplicationDocumentsDirectory();
        final newPath = '${dir.path}/frontFiles/${const Uuid().v4()}${frontFile.path.split('.').last}';
        await frontFile.copy(newPath);
        back = newPath;
      }

      final newWord = WordModel(
        id: UniqueKey().toString(),
        front: front,
        back: back,
        frontType: widget.frontType,
        backType: widget.backType,
        packageId: widget.packageId,
      );
      await AppDatabase.instance.createWord(newWord);
      if (mounted) {
        Navigator.of(context).pop(newWord);
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _submissionStatus = FormzSubmissionStatus.failure;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add word')));
      }
    }
  }

  @override
  void dispose() {
    _frontText.dispose();
    _backText.dispose();
    super.dispose();
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
          const Text('Front:'),
          if (widget.frontType == DisplayType.text)
            TextField(
              controller: _frontText,
              enabled: !_submissionStatus.isInProgress,
            )
          else if (widget.frontType == DisplayType.image)
            IgnorePointer(
              ignoring: _submissionStatus.isInProgress,
              child: _ImageView(
                onImageChanged: (img) {
                  setState(() {
                    _frontText.text = img.path;
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          const Text('Back:'),
          if (widget.backType == DisplayType.text)
            TextField(
              controller: _backText,
              enabled: !_submissionStatus.isInProgress,
            )
          else if (widget.backType == DisplayType.image)
            IgnorePointer(
              ignoring: _submissionStatus.isInProgress,
              child: _ImageView(onImageChanged: (img) {
                setState(() {
                  _backText.text = img.path;
                });
              }),
            ),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _submissionStatus.isInProgress ? null : _submit,
              child: _submissionStatus.isInProgress ? const CircularProgressIndicator.adaptive() : const Text('Add')),
        ],
      ),
    );
  }
}

class _ImageView extends StatefulWidget {
  const _ImageView({
    required this.onImageChanged,
  });

  final void Function(File)? onImageChanged;

  @override
  State<_ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<_ImageView> {
  File? image;

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        this.image = File(image.path);
      });
      widget.onImageChanged?.call(this.image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: image == null
          ? IconButton(
              icon: const Icon(Icons.add),
              onPressed: _pickImage,
            )
          : Image.file(image!),
    );
  }
}
