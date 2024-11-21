class WordSuggestion {
  final String word;
  final String type;
  final String? definition;
  final List<String> synonyms;

  WordSuggestion({
    required this.word,
    required this.type,
    this.definition,
    this.synonyms = const [],
  });

  factory WordSuggestion.fromJson(Map<String, dynamic> json) {
    return WordSuggestion(
      word: json['word'] as String,
      type: json['type'] as String? ?? 'unknown',
      definition: json['definition'] as String?,
      synonyms: (json['synonyms'] as List?)?.cast<String>() ?? [],
    );
  }
} 