import 'dart:io';

import 'package:demo_app/data/database.dart';
import 'package:demo_app/data/models.dart';
import 'package:demo_app/ui/add_package/add_package_screen.dart';
import 'package:demo_app/ui/word_list/word_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<PackageModel> _packages = [];
  FormzSubmissionStatus _getPackagesStatus = FormzSubmissionStatus.initial;

  Future<void> _getPackages() async {
    try {
      setState(() {
        _getPackagesStatus = FormzSubmissionStatus.inProgress;
        _packages = [];
      });
      final data = await AppDatabase.instance.getPackages();
      setState(() {
        _getPackagesStatus = FormzSubmissionStatus.success;
        _packages = data;
      });
    } catch (e) {
      setState(() {
        _getPackagesStatus = FormzSubmissionStatus.failure;
        _packages = [];
      });
    }
  }

  Future<void> _addPackage() async {
    final PackageModel? newPackage = await Navigator.of(context).push<PackageModel>(AddPackageScreen.route());
    if (newPackage != null) {
      setState(() {
        _packages.add(newPackage);
      });
    }
  }

  Future<void> _onDeletePackage(int index) => AppDatabase.instance.deletePackage(_packages[index].id).then((_) {
        setState(() {
          _packages.removeAt(index);
        });
      });

  @override
  void initState() {
    _getPackages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: _addPackage, icon: const Icon(Icons.add)),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_getPackagesStatus.isFailure) {
            return Center(
              child: Column(
                children: [
                  const Text(
                    'Error getting packages',
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  FilledButton(onPressed: _getPackages, child: const Text('Retry')),
                ],
              ),
            );
          }
          if (_getPackagesStatus.isSuccess) {
            return ListView.builder(
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final package = _packages[index];
                return ListTile(
                  title: Text(package.title),
                  subtitle: Text(package.description),
                  leading: Image.file(
                    File(package.image),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _onDeletePackage(index),
                  ),
                  onTap: () => Navigator.of(context).push(WordListScreen.route(package)),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
