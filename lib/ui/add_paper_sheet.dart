import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paper.dart';
import '../data/papers.dart';
import '../state/app_state.dart';

class AddPaperSheet extends StatefulWidget {
  const AddPaperSheet({super.key});

  @override
  State<AddPaperSheet> createState() => _AddPaperSheetState();
}

class _AddPaperSheetState extends State<AddPaperSheet> {
  final _nameController = TextEditingController();
  final _nameBnController = TextEditingController();
  final _rssController = TextEditingController();
  final _websiteController = TextEditingController();
  final Set<String> _selectedCategories = {'জাতীয়'};

  @override
  void dispose() {
    _nameController.dispose();
    _nameBnController.dispose();
    _rssController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'নতুন পত্রিকা যোগ করুন',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameBnController,
              decoration: const InputDecoration(
                labelText: 'বাংলা নাম *',
                hintText: 'যেমন: প্রথম আলো',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ইংরেজি নাম',
                hintText: 'Prothom Alo',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rssController,
              decoration: const InputDecoration(
                labelText: 'RSS URL *',
                hintText: 'https://example.com/feed/',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'ওয়েবসাইট',
                hintText: 'https://example.com',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            Text('ক্যাটাগরি', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PapersData.allCategories
                  .where((c) => c != 'সব')
                  .map((cat) {
                final selected = _selectedCategories.contains(cat);
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedCategories.add(cat);
                      } else {
                        _selectedCategories.remove(cat);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('যোগ করুন'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    final nameBn = _nameBnController.text.trim();
    final rss = _rssController.text.trim();

    if (nameBn.isEmpty || rss.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বাংলা নাম ও RSS URL আবশ্যক')),
      );
      return;
    }

    final paper = Paper(
      id: '',
      name: _nameController.text.trim().isEmpty
          ? nameBn
          : _nameController.text.trim(),
      nameBn: nameBn,
      logoUrl: '',
      rssUrl: rss,
      website: _websiteController.text.trim().isEmpty
          ? rss
          : _websiteController.text.trim(),
      categories: _selectedCategories.toList(),
      isCustom: true,
    );

    context.read<AppState>().addCustomPaper(paper);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nameBn যোগ করা হয়েছে')),
    );
  }
}
