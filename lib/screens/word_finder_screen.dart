import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:word_finder/services/word_service.dart';
import 'package:word_finder/models/word_suggestion.dart';
import 'package:word_finder/screens/word_details_screen.dart';
import 'package:word_finder/screens/settings_screen.dart';

class WordFinderScreen extends StatefulWidget {
  const WordFinderScreen({super.key});

  @override
  State<WordFinderScreen> createState() => _WordFinderScreenState();
}

class _WordFinderScreenState extends State<WordFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WordService _wordService = WordService();
  List<String> searchHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(flex: 1),
          
          // Welcome Text and Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Find the Right Word',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Type a word to get definitions, synonyms, and pronunciation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),
          
          // Search box and suggestions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TypeAheadField<WordSuggestion>(
              suggestionsCallback: (pattern) async {
                if (pattern.length < 2) return [];
                return await _wordService.getSuggestions(pattern);
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter a word...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                );
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.word),
                  subtitle: Text(suggestion.type),
                );
              },
              onSelected: (suggestion) {
                setState(() {
                  searchHistory.insert(0, suggestion.word);
                  if (searchHistory.length > 10) {
                    searchHistory.removeLast();
                  }
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordDetailsScreen(
                      word: suggestion.word,
                      searchHistory: searchHistory,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          
          // Recent searches section
          if (searchHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            searchHistory.clear();
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: searchHistory.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(searchHistory[index]),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _searchController.text = searchHistory[index];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WordDetailsScreen(
                                    word: searchHistory[index],
                                    searchHistory: searchHistory,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Show suggestions when no history
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Try searching for:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      'serendipity',
                      'ephemeral',
                      'ubiquitous',
                      'eloquent',
                    ].map((word) => ActionChip(
                      label: Text(word),
                      onPressed: () {
                        _searchController.text = word;
                        // Trigger search
                      },
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 