import 'package:flutter/material.dart';
import 'package:word_finder/screens/word_finder_screen.dart';
import 'package:word_finder/screens/phrase_finder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WordFinderScreen(), // We'll start with WordFinderScreen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PhraseFinderScreen()),
            );
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
} 