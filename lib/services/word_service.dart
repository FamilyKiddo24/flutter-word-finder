import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:word_finder/models/word_suggestion.dart';

class WordService {
  // Using the Free Dictionary API
  static const String _baseUrl = 'https://api.datamuse.com';
  static const String _dictionaryApi = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  Future<List<WordSuggestion>> getSuggestions(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sug?s=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.take(10).map((item) => WordSuggestion(
          word: item['word'],
          type: 'word', // The free API doesn't provide word type directly
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  Future<WordSuggestion> getWordDetails(String word) async {
    try {
      // Get definition and type from Dictionary API
      final dictResponse = await http.get(Uri.parse('$_dictionaryApi/$word'));
      
      if (dictResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(dictResponse.body);
        final meanings = data[0]['meanings'] as List;
        final firstMeaning = meanings[0];
        
        // Get synonyms from Datamuse API
        final synResponse = await http.get(
          Uri.parse('$_baseUrl/words?rel_syn=$word&max=5'),
        );
        
        List<String> synonyms = [];
        if (synResponse.statusCode == 200) {
          final List<dynamic> synData = json.decode(synResponse.body);
          synonyms = synData.map<String>((item) => item['word'] as String).toList();
        }

        return WordSuggestion(
          word: word,
          type: firstMeaning['partOfSpeech'] ?? 'unknown',
          definition: firstMeaning['definitions'][0]['definition'],
          synonyms: synonyms,
        );
      }
      
      return WordSuggestion(
        word: word,
        type: 'unknown',
        definition: 'No definition found',
        synonyms: [],
      );
    } catch (e) {
      print('Error fetching word details: $e');
      return WordSuggestion(
        word: word,
        type: 'unknown',
        definition: 'Error loading definition',
        synonyms: [],
      );
    }
  }
} 