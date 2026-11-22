import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/location.dart';
import '../providers/location_provider.dart';

class AddLocationDialog extends StatefulWidget {
  const AddLocationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => const AddLocationDialog(),
    );
  }

  @override
  State<AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lonCtrl = TextEditingController();
  LocationTag _selectedTag = LocationTag.home;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _countryCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Saved Location'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Location Name (e.g. South Delhi, Downtown)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countryCtrl,
              decoration: const InputDecoration(labelText: 'Country / Region'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    decoration: const InputDecoration(labelText: 'Latitude (e.g. 28.613)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lonCtrl,
                    decoration: const InputDecoration(labelText: 'Longitude (e.g. 77.209)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LocationTag>(
              initialValue: _selectedTag,
              decoration: const InputDecoration(labelText: 'Household Category Tag'),
              items: LocationTag.values.map((tag) {
                return DropdownMenuItem(value: tag, child: Text(tag.label));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTag = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer(
          builder: (context, ref, _) => ElevatedButton(
            onPressed: () {
              final name = _nameCtrl.text.trim();
              final country = _countryCtrl.text.trim();
              final lat = double.tryParse(_latCtrl.text.trim()) ?? 0.0;
              final lon = double.tryParse(_lonCtrl.text.trim()) ?? 0.0;

              if (name.isNotEmpty) {
                final newLoc = LocationItem(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  country: country,
                  latitude: lat,
                  longitude: lon,
                  tag: _selectedTag,
                );
                ref.read(locationProvider.notifier).addOrUpdateLocation(newLoc);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save Location'),
          ),
        ),
      ],
    );
  }
}
