import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:word_finder/config/api_config.dart';

class PhraseFinderScreen extends StatefulWidget {
  const PhraseFinderScreen({super.key});

  @override
  State<PhraseFinderScreen> createState() => _PhraseFinderScreenState();
}

class _PhraseFinderScreenState extends State<PhraseFinderScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isLoading = false;
  
  // Initialize Gemini AI
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: ApiConfig.geminiApiKey,
  );

  Future<void> _improvePhrase() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final content = [
        Content.text(
          'Improve this phrase and make it more detailed and professional: ${_inputController.text}',
        ),
      ];

      final response = await model.generateContent(content);
      
      setState(() {
        _outputController.text = response.text ?? 'No suggestion available';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _outputController.text = 'Error: Unable to process your request';
        _isLoading = false;
      });
      print('Error improving phrase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phrase Finder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your phrase:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Type your phrase here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _improvePhrase,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Improve Phrase'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_outputController.text.isNotEmpty) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Improved Version:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _outputController,
                        maxLines: 5,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _inputController.text = _outputController.text;
                              _outputController.clear();
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit This Version'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Word Finder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Phrase Finder',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
} 