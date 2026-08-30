import 'package:flutter/material.dart';

import '../../theme_controller.dart';
import '../../widgets/section_card.dart';

enum LlmProvider { claude, ollama }

/// App settings: LLM provider configuration.
///
/// Intervals.icu connection lives on the Profile screen (it's a login, not
/// a setting). TODO: persist these choices (e.g. secure storage) and use
/// them to configure the embedded LangChain agent / MCP client.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LlmProvider _provider = LlmProvider.claude;
  final _ollamaUrlController = TextEditingController(
    text: 'http://localhost:11434',
  );

  @override
  void dispose() {
    _ollamaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            icon: Icons.brightness_6_outlined,
            title: 'Appearance',
            child: ListenableBuilder(
              listenable: ThemeController.instance,
              builder: (context, _) => SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {ThemeController.instance.mode},
                onSelectionChanged: (selection) =>
                    ThemeController.instance.setMode(selection.first),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.auto_awesome_outlined,
            title: 'LLM provider',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<LlmProvider>(
                  segments: const [
                    ButtonSegment(
                      value: LlmProvider.claude,
                      label: Text('Claude'),
                      icon: Icon(Icons.bolt_outlined),
                    ),
                    ButtonSegment(
                      value: LlmProvider.ollama,
                      label: Text('Ollama'),
                      icon: Icon(Icons.dns_outlined),
                    ),
                  ],
                  selected: {_provider},
                  onSelectionChanged: (selection) =>
                      setState(() => _provider = selection.first),
                ),
                const SizedBox(height: 14),
                if (_provider == LlmProvider.ollama)
                  TextField(
                    controller: _ollamaUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Ollama server URL',
                    ),
                  )
                else
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Claude API key'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
