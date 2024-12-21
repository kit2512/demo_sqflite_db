import 'dart:io';

import 'package:demo_app/data/database.dart';
import 'package:demo_app/data/models.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddPackageScreen extends StatefulWidget {
  const AddPackageScreen({super.key});

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();

  static MaterialPageRoute<PackageModel> route() {
    return MaterialPageRoute<PackageModel>(
      builder: (_) => const AddPackageScreen(),
    );
  }
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  File? _image;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = file == null ? null : File(file.path);
    });
  }

  FormzSubmissionStatus _submissionStatus = FormzSubmissionStatus.initial;
  void _submit() async {
    try {
      if (_formKey.currentState?.validate() == false || _image == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        setState(() {
          _submissionStatus = FormzSubmissionStatus.failure;
        });
        return;
      }
      setState(() {
        _submissionStatus = FormzSubmissionStatus.inProgress;
      });

      final title = _titleController.text;
      final description = _descriptionController.text;
      final newPackage = PackageModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        image: _image!.path,
      );
      AppDatabase.instance.createPackage(newPackage);
      setState(() {
        _submissionStatus = FormzSubmissionStatus.success;
      });
      Navigator.of(context).pop(newPackage);
    } catch (e) {
      setState(() {
        _submissionStatus = FormzSubmissionStatus.failure;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create package')));
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add package'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  child: _image == null
                      ? const Icon(Icons.add_a_photo)
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              validator: (e) => (e?.isNotEmpty ?? false) ? null : 'Title is required',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              enabled: _submissionStatus.isInProgress ? false : true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              validator: (e) => (e?.isNotEmpty ?? false) ? null : 'Description is required',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              enabled: _submissionStatus.isInProgress ? false : true,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submissionStatus.isInProgress ? null : _submit,
              child: _submissionStatus.isInProgress ? const CircularProgressIndicator.adaptive() : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
