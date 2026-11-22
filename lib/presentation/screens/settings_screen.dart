import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/aqi_standards.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _endpointController;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _apiKeyController = TextEditingController(text: settings.genAiApiKey);
    _endpointController = TextEditingController(text: settings.genAiEndpoint);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'APPLICATION PREFERENCES & AI SETUP',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D9488),
                  ),
            ),
            Text(
              'Settings & Integrations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize appearance, air-quality measurement standards, accessibility, and optional GenAI provider connections.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 20),

            // Display & Theme Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Appearance & Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Theme Mode'),
                      subtitle: Text(settings.themeMode == ThemeMode.system
                          ? 'Follow System'
                          : settings.themeMode == ThemeMode.dark
                              ? 'Deep Navy Dark Theme'
                              : 'Clean White Light Theme'),
                      trailing: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16), label: Text('Light')),
                          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16), label: Text('Dark')),
                          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_brightness, size: 16), label: Text('Auto')),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (set) {
                          ref.read(settingsProvider.notifier).updateThemeMode(set.first);
                        },
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      secondary: const Icon(Icons.animation_outlined),
                      title: const Text('Reduced Motion'),
                      subtitle: const Text('Disable animations and transitions for accessibility (WCAG 2.2 AA)'),
                      value: settings.reducedMotion,
                      onChanged: (val) => ref.read(settingsProvider.notifier).toggleReducedMotion(val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AQI Standard Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Air Quality Scale Standard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how category thresholds and color bands are calculated.',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12),
                    RadioGroup<AqiStandard>(
                      groupValue: settings.aqiStandard,
                      onChanged: (val) {
                        if (val != null) ref.read(settingsProvider.notifier).updateAqiStandard(val);
                      },
                      child: Column(
                        children: AqiStandard.values.map((std) {
                          return RadioListTile<AqiStandard>(
                            title: Text(std.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(std.description, style: const TextStyle(fontSize: 12)),
                            value: std,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // GenAI Provider Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFF0D9488)),
                            SizedBox(width: 8),
                            Text('GenAI Provider Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Switch(
                          value: settings.useRealGenAi,
                          onChanged: (val) {
                            ref.read(settingsProvider.notifier).updateGenAiConfig(
                                  useRealGenAi: val,
                                  apiKey: _apiKeyController.text,
                                  endpoint: _endpointController.text,
                                );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: const Text(
                        'Security & Privacy Architecture: No API keys are hardcoded in the client source code. When GenAI is disabled or unconfigured, ClearAir AI runs deterministic, evidence-based local algorithms labeled as [Demo Mode - Deterministic Assistant]. We never claim rule-based logic is an LLM.',
                        style: TextStyle(fontSize: 11, height: 1.35),
                      ),
                    ),
                    if (settings.useRealGenAi) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: _obscureKey,
                        decoration: InputDecoration(
                          labelText: 'Gemini / LLM API Key (Stored Locally)',
                          hintText: 'Enter your API key',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureKey = !_obscureKey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _endpointController,
                        decoration: const InputDecoration(
                          labelText: 'API Endpoint / Secure Proxy URL',
                          hintText: 'https://generativelanguage.googleapis.com/...',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(settingsProvider.notifier).updateGenAiConfig(
                                  useRealGenAi: true,
                                  apiKey: _apiKeyController.text.trim(),
                                  endpoint: _endpointController.text.trim(),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('GenAI credentials saved locally!')),
                            );
                          },
                          child: const Text('Save AI Credentials'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Demo Mode & Privacy Reset Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data, Privacy & Demo Simulation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      secondary: const Icon(Icons.science_outlined),
                      title: const Text('Force Demo Mode Datasets'),
                      subtitle: const Text('Uses curated winter smog and ozone simulation datasets for deterministic testing'),
                      value: settings.isDemoMode,
                      onChanged: (val) => ref.read(settingsProvider.notifier).toggleDemoMode(val),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                      title: const Text('Reset All Local Data & Profile', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Clears saved locations, household demographics, routines, and cache from device storage.'),
                      trailing: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        onPressed: () => _confirmReset(context),
                        child: const Text('Reset Data'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // About ClearAir AI
            Center(
              child: Column(
                children: [
                  const Text('ClearAir AI — Version 1.0.0 (Production Release)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    'Breathe smarter. Live healthier. Reduce pollution together.',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Complete Reset'),
        content: const Text('Are you sure you want to erase all locally saved locations, household preferences, routines, and cached air quality data? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(settingsProvider.notifier).resetAllData();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All local data and preferences have been cleared.')),
              );
            },
            child: const Text('Erase All Data'),
          ),
        ],
      ),
    );
  }
}
