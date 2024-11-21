import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:word_finder/services/word_service.dart';
import 'package:word_finder/screens/phrase_finder_screen.dart';

class WordDetailsScreen extends StatefulWidget {
  final String word;
  final List<String> searchHistory;

  const WordDetailsScreen({
    super.key,
    required this.word,
    required this.searchHistory,
  });

  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final WordService _wordService = WordService();
  bool isLoading = true;
  String? definition;
  String? wordType;
  List<String> synonyms = [];
  
  @override
  void initState() {
    super.initState();
    _loadWordDetails();
  }

  Future<void> _loadWordDetails() async {
    setState(() => isLoading = true);
    final details = await _wordService.getWordDetails(widget.word);
    setState(() {
      definition = details.definition;
      wordType = details.type;
      synonyms = details.synonyms;
      isLoading = false;
    });
  }

  Future<void> _speakWord() async {
    await flutterTts.speak(widget.word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.word),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            widget.word,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: _speakWord,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type: ${wordType ?? "Unknown"}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Definition:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(definition ?? 'No definition available'),
                        ],
                      ),
                    ),
                  ),
                  if (synonyms.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Synonyms:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: synonyms
                                  .map((syn) => Chip(
                                        label: Text(syn),
                                        onDeleted: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WordDetailsScreen(
                                                word: syn,
                                                searchHistory: widget.searchHistory,
                                              ),
                                            ),
                                          );
                                        },
                                        deleteIcon: const Icon(Icons.arrow_forward),
                                      ))
                                  .toList(),
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            // Navigate to PhraseFinderScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PhraseFinderScreen(),
              ),
            );
          } else {
            // Go back to WordFinderScreen
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
    flutterTts.stop();
    super.dispose();
  }
} 